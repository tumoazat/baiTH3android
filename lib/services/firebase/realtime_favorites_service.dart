import 'package:firebase_database/firebase_database.dart';
import '../../models/user_favorite.dart';
import '../../utils/constants.dart';

class RealtimeFavoritesService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Stream<List<UserFavorite>> streamFavorites(String userId) {
    final ref = _database.ref('favorites').orderByChild('userId').equalTo(userId);
    return ref.onValue.map((event) {
      final favorites = <UserFavorite>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          final favData = Map<String, dynamic>.from(value as Map);
          favData['id'] = key; // Add the key as id
          favorites.add(UserFavorite.fromJson(favData, key));
        });
      }
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
      });
    } catch (e) {
      throw Exception('Realtime DB error: $e');
    }
  }

  Future<void> removeFavorite(String docId) async {
    try {
      await _database.ref('favorites/$docId').remove();
    } catch (e) {
      throw Exception('Realtime DB error: $e');
    }
  }

  Future<bool> isFavorite(String userId, String itemId) async {
    try {
      final snapshot = await _database
          .ref('favorites')
          .orderByChild('userId')
          .equalTo(userId)
          .get();
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
