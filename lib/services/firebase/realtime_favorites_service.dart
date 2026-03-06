import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/user_favorite.dart';
import '../../utils/constants.dart';

class RealtimeFavoritesService {
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://appmenu-4de2f-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
  Map<String, List<UserFavorite>> _cache = {};

  Stream<List<UserFavorite>> streamFavorites(String userId) {
    final ref = _database.ref('userFavorites/$userId');
    
    print('🔄 Loading favorites for user: $userId');
    
    return ref.onValue.map((event) {
      final favorites = <UserFavorite>[];
      
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((itemId, value) {
          final favData = Map<String, dynamic>.from(value as Map);
          favData['itemId'] = itemId;
          favData['userId'] = userId;
          favData['id'] = itemId;
          
          favorites.add(UserFavorite.fromJson(favData, itemId));
        });
      }
      
      print('✅ Favorites loaded: ${favorites.length}');
      _cache[userId] = favorites;
      
      return favorites;
    }).handleError((e) {
      print('❌ Stream error: $e');
    });
  }

  Future<void> addFavorite(UserFavorite favorite) async {
    try {
      await _database.ref('userFavorites/${favorite.userId}/${favorite.itemId}').set({
        'itemType': favorite.itemType,
        'itemName': favorite.itemName,
        'itemImageUrl': favorite.itemImageUrl,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      _cache.clear();
    } catch (e) {
      throw Exception('Realtime DB error: $e');
    }
  }

  Future<void> removeFavoriteByUserAndItem(String userId, String itemId) async {
    try {
      await _database.ref('userFavorites/$userId/$itemId').remove();
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
          .get();
      
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }
}
