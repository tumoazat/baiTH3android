import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/api/restaurant_api_service.dart';

enum RestaurantLoadingState { idle, loading, success, error }

class RestaurantProvider extends ChangeNotifier {
  final RestaurantApiService _service = RestaurantApiService();

  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  RestaurantLoadingState _state = RestaurantLoadingState.idle;
  String _errorMessage = '';
  String _searchQuery = '';

  List<Restaurant> get restaurants => _filteredRestaurants;
  RestaurantLoadingState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == RestaurantLoadingState.loading;
  bool get hasError => _state == RestaurantLoadingState.error;

  Future<void> fetchRestaurants() async {
    _state = RestaurantLoadingState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _restaurants = await _service.fetchRestaurants();
      _applyFilter();
      _state = RestaurantLoadingState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = RestaurantLoadingState.error;
    }
    notifyListeners();
  }

  Future<void> retry() => fetchRestaurants();

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredRestaurants = List.from(_restaurants);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredRestaurants = _restaurants
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.cuisine.toLowerCase().contains(q) ||
              r.category.toLowerCase().contains(q))
          .toList();
    }
  }
}
