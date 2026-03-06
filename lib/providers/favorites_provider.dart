import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_favorite.dart';
import '../services/firebase/favorites_service.dart';
import '../utils/constants.dart';

enum FavoritesLoadingState { idle, loading, success, error }

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _service = FavoritesService();

  List<UserFavorite> _favorites = [];
  FavoritesLoadingState _state = FavoritesLoadingState.idle;
  String _errorMessage = '';
  StreamSubscription<List<UserFavorite>>? _subscription;
  bool _firebaseAvailable = true;

  List<UserFavorite> get favorites => _favorites;
  FavoritesLoadingState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == FavoritesLoadingState.loading;
  bool get hasError => _state == FavoritesLoadingState.error;

  void listenToFavorites(String userId) {
    _subscription?.cancel();
    _state = FavoritesLoadingState.loading;
    notifyListeners();
    try {
      _subscription = _service.streamFavorites(userId).listen(
        (list) {
          _favorites = list;
          _state = FavoritesLoadingState.success;
          _firebaseAvailable = true;
          notifyListeners();
        },
        onError: (e) {
          _errorMessage =
              'Không thể tải danh sách yêu thích. Vui lòng kiểm tra kết nối.';
          _state = FavoritesLoadingState.error;
          _firebaseAvailable = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Firebase chưa được cấu hình.';
      _state = FavoritesLoadingState.error;
      _firebaseAvailable = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite({
    required String userId,
    required String itemId,
    required String itemType,
    required String itemName,
    required String itemImageUrl,
  }) async {
    if (!_firebaseAvailable) return;
    try {
      final fav = UserFavorite(
        id: '',
        userId: userId,
        itemId: itemId,
        itemType: itemType,
        itemName: itemName,
        itemImageUrl: itemImageUrl,
        createdAt: DateTime.now(),
      );
      await _service.addFavorite(fav);
    } catch (e) {
      _errorMessage = 'Không thể thêm yêu thích.';
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String docId) async {
    if (!_firebaseAvailable) return;
    try {
      await _service.removeFavorite(docId);
    } catch (e) {
      _errorMessage = 'Không thể xóa yêu thích.';
      notifyListeners();
    }
  }

  bool isFavorite(String itemId) =>
      _favorites.any((f) => f.itemId == itemId);

  UserFavorite? getFavorite(String itemId) =>
      _favorites.cast<UserFavorite?>().firstWhere(
            (f) => f?.itemId == itemId,
            orElse: () => null,
          );

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> retry(String userId) async {
    listenToFavorites(userId);
  }

  void clear() {
    stopListening();
    _favorites = [];
    _state = FavoritesLoadingState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
