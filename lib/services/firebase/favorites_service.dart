import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_favorite.dart';
import '../../utils/constants.dart';
import 'firestore_service.dart';

class FavoritesService {
  final FirestoreService _firestore = FirestoreService();

  Stream<List<UserFavorite>> streamFavorites(String userId) {
    return _firestore
        .streamCollection(
          AppConstants.favoritesCollection,
          whereField: 'userId',
          whereValue: userId,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => UserFavorite.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> addFavorite(UserFavorite favorite) async {
    await _firestore.addDocument(
      AppConstants.favoritesCollection,
      favorite.toJson(),
    );
  }

  Future<void> removeFavorite(String docId) async {
    await _firestore.deleteDocument(AppConstants.favoritesCollection, docId);
  }

  Future<bool> isFavorite(String userId, String itemId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.favoritesCollection)
          .where('userId', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .get();
      return snapshot.docs.isNotEmpty;
    } on FirebaseException {
      return false;
    }
  }
}
