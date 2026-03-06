import 'package:firebase_database/firebase_database.dart';
import '../../models/user_favorite.dart';
import '../../utils/constants.dart';

class RealtimeFavoritesService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  Map<String, List<UserFavorite>> _cache = {};

  Stream<List<UserFavorite>> streamFavorites(String userId) {
    // Use better structure: favorites/{userId}/{itemId}
    // This is much faster than querying all favorites by userId
    final ref = _database.ref('userFavorites/$userId');
    
    print('🔄 Loading favorites for user: $userId');
    
    return ref.onValue
        .timeout(
          const Duration(seconds: 8),
          onTimeout: (sink) {
            print('⏱️ Favorites timeout after 8 seconds');
            sink.close();
          },
        )
        .map((event) {
      final favorites = <UserFavorite>[];
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          print('✅ Loaded ${data.length} favorites');
          data.forEach((itemId, value) {
            try {
              final favData = Map<String, dynamic>.from(value as Map);
              favData['itemId'] = itemId;
              favData['userId'] = userId;
              favData['id'] = itemId;
              favorites.add(UserFavorite.fromJson(favData, itemId));
            } catch (e) {
              print('❌ Error parsing favorite $itemId: $e');
            }
          });
        } catch (e) {
          print('❌ Error processing favorites: $e');
        }
      } else {
        print('📭 No favorites data found');
      }
      // Cache the result
      _cache[userId] = favorites;
      return favorites;
    }).handleError((e) {
      print('❌ Stream error: $e');
    });
  }

  Future<void> addFavorite(UserFavorite favorite) async {
    try {
      // Store in userFavorites/{userId}/{itemId} structure
      await _database.ref('userFavorites/${favorite.userId}/${favorite.itemId}').set({
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
      // docId here is actually itemId, but we need userId
      // This method needs to be updated - will handle in provider
      await Future.delayed(Duration.zero);
    } catch (e) {
      throw Exception('Realtime DB error: $e');
    }
  }

  Future<void> removeFavoriteByUserAndItem(String userId, String itemId) async {
    try {
      await _database.ref('userFavorites/$userId/$itemId').remove().timeout(
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
          .ref('userFavorites/$userId/$itemId')
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Check favorite timeout'),
          );
      
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }
}
