import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_favorite.dart';
import '../services/firebase/realtime_favorites_service.dart';
import '../utils/constants.dart';

enum FavoritesLoadingState { idle, loading, success, error }

class FavoritesProvider extends ChangeNotifier {
  final RealtimeFavoritesService _service = RealtimeFavoritesService();

  List<UserFavorite> _favorites = [];
  FavoritesLoadingState _state = FavoritesLoadingState.idle;
  String _errorMessage = '';
  StreamSubscription<List<UserFavorite>>? _subscription;
  bool _firebaseAvailable = true;
  String _currentUserId = '';
  Timer? _loadingTimeout;

  List<UserFavorite> get favorites => _favorites;
  FavoritesLoadingState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == FavoritesLoadingState.loading;
  bool get hasError => _state == FavoritesLoadingState.error;

  void listenToFavorites(String userId) {
    _currentUserId = userId;
    _subscription?.cancel();
    _loadingTimeout?.cancel();
    _state = FavoritesLoadingState.loading;
    notifyListeners();

    // Nếu sau 5 giây vẫn chưa có dữ liệu -> hiển thị rỗng thay vì loading mãi
    _loadingTimeout = Timer(const Duration(seconds: 5), () {
      if (_state == FavoritesLoadingState.loading) {
        _favorites = [];
        _state = FavoritesLoadingState.success;
        notifyListeners();
      }
    });

    try {
      _subscription = _service.streamFavorites(userId).listen(
        (list) {
          _loadingTimeout?.cancel();
          _favorites = list;
          _state = FavoritesLoadingState.success;
          _firebaseAvailable = true;
          _errorMessage = '';
          notifyListeners();
        },
        onError: (e) {
          _loadingTimeout?.cancel();
          print('Favorites error: $e');
          _favorites = [];
          _state = FavoritesLoadingState.success; // Hiển thị rỗng thay vì lỗi
          _firebaseAvailable = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _loadingTimeout?.cancel();
      print('Favorites catch error: $e');
      _favorites = [];
      _state = FavoritesLoadingState.success;
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
      _firebaseAvailable = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể thêm yêu thích.';
      _firebaseAvailable = false;
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String itemId) async {
    try {
      await _service.removeFavoriteByUserAndItem(_currentUserId, itemId);
      _firebaseAvailable = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể xóa yêu thích.';
      _firebaseAvailable = false;
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
    _loadingTimeout?.cancel();
    _loadingTimeout = null;
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
    _loadingTimeout?.cancel();
    super.dispose();
  }
}
