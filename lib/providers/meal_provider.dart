import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/api/meal_api_service.dart';

enum MealLoadingState { idle, loading, success, error }

class MealProvider extends ChangeNotifier {
  final MealApiService _service = MealApiService();

  List<Meal> _meals = [];
  List<String> _categories = [];
  MealLoadingState _state = MealLoadingState.idle;
  String _errorMessage = '';
  String _selectedCategory = 'Beef';

  List<Meal> get meals => _meals;
  List<String> get categories => _categories;
  MealLoadingState get state => _state;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _state == MealLoadingState.loading;
  bool get hasError => _state == MealLoadingState.error;

  Future<void> fetchCategories() async {
    try {
      _categories = await _service.fetchCategories();
      if (_categories.isNotEmpty && !_categories.contains(_selectedCategory)) {
        _selectedCategory = _categories.first;
      }
      notifyListeners();
    } catch (_) {
      _categories = [
        'Beef', 'Chicken', 'Seafood', 'Vegetarian',
        'Pasta', 'Dessert', 'Breakfast',
      ];
      notifyListeners();
    }
  }

  Future<void> fetchMealsByCategory(String category) async {
    _selectedCategory = category;
    _state = MealLoadingState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _meals = await _service.fetchMealsByCategory(category);
      _state = MealLoadingState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = MealLoadingState.error;
    }
    notifyListeners();
  }

  Future<void> searchMeals(String query) async {
    if (query.isEmpty) {
      fetchMealsByCategory(_selectedCategory);
      return;
    }
    _state = MealLoadingState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _meals = await _service.searchMeals(query);
      _state = MealLoadingState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = MealLoadingState.error;
    }
    notifyListeners();
  }

  Future<void> retry() => fetchMealsByCategory(_selectedCategory);
}
