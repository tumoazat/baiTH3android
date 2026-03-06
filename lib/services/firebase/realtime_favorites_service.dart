import 'package:firebase_database/firebase_database.dart';
import '../../models/user_favorite.dart';
import '../../utils/constants.dart';

class RealtimeFavoritesService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  Map<String, List<UserFavorite>> _cache = {};

  Stream<List<UserFavorite>> streamFavorites(String userId) {
    // Set timeout for Realtime Database operations
    _database.ref().keepSynced(true);
    
    final ref = _database.ref('favorites').orderByChild('userId').equalTo(userId);
    return ref.onValue
        .timeout(
          const Duration(seconds: 15),
          onTimeout: (sink) {
            // Close the stream on timeout
            sink.close();
          },
        )
        .map((event) {
      final favorites = <UserFavorite>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          try {
            final favData = Map<String, dynamic>.from(value as Map);
            favData['id'] = key;
            favorites.add(UserFavorite.fromJson(favData, key));
          } catch (e) {
            print('Error parsing favorite: $e');
          }
        });
      }
      // Cache the result
      _cache[userId] = favorites;
      return favorites;
    });
  }

  Future<void> addFavorite(UserFavorite favorite) async {
    try {
      final newRef = _database.ref('favorites').push();
      await newRef.set({
        'userId': favorite.userId,
        'itemId': favorite.itemId,
        'itemType': favorite.itemType,
        'itemName': favorite.itemName,
        'itemImageUrl': favorite.itemImageUrl,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Add favorite timeout'),
      );
      // Clear cache after adding
      _cache.clear();
    } catch (e) {
      throw Exception('Realtime DB error: $e');
    }
  }

  Future<void> removeFavorite(String docId) async {
    try {
      await _database.ref('favorites/$docId').remove().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Remove favorite timeout'),
      );
      // Clear cache after removing
      _cache.clear();
    } catch (e) {
      throw Exception('Realtime DB error: $e');
    }
  }

  Future<bool> isFavorite(String userId, String itemId) async {
    try {
      // Check cache first
      if (_cache.containsKey(userId)) {
        return _cache[userId]!.any((f) => f.itemId == itemId);
      }
      
      final snapshot = await _database
          .ref('favorites')
          .orderByChild('userId')
          .equalTo(userId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Check favorite timeout'),
          );
      
      if (snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.values.any((v) {
          final fav = Map<String, dynamic>.from(v as Map);
          return fav['itemId'] == itemId;
        });
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
