import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/meal.dart';
import '../../utils/constants.dart';

class MealApiService {
  static const Duration _timeout = Duration(seconds: 10);

  Future<List<String>> fetchCategories() async {
    final response = await http
        .get(Uri.parse('${AppConstants.mealBaseUrl}/categories.php'))
        .timeout(_timeout);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final categories = data['categories'] as List;
      return categories
          .map((c) => c['strCategory'].toString())
          .toList();
    }
    throw Exception('Không thể tải danh mục: ${response.statusCode}');
  }

  Future<List<Meal>> fetchMealsByCategory(String category) async {
    final response = await http
        .get(
            Uri.parse('${AppConstants.mealBaseUrl}/filter.php?c=$category'))
        .timeout(_timeout);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final meals = data['meals'];
      if (meals == null) return [];
      return (meals as List)
          .map((e) => Meal.fromListJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Không thể tải món ăn: ${response.statusCode}');
  }

  Future<Meal?> fetchMealDetail(String id) async {
    final response = await http
        .get(Uri.parse('${AppConstants.mealBaseUrl}/lookup.php?i=$id'))
        .timeout(_timeout);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final meals = data['meals'];
      if (meals == null || (meals as List).isEmpty) return null;
      return Meal.fromJson(meals.first as Map<String, dynamic>);
    }
    throw Exception('Không thể tải chi tiết: ${response.statusCode}');
  }

  Future<List<Meal>> searchMeals(String query) async {
    if (query.isEmpty) return [];
    final response = await http
        .get(Uri.parse(
            '${AppConstants.mealBaseUrl}/search.php?s=${Uri.encodeComponent(query)}'))
        .timeout(_timeout);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final meals = data['meals'];
      if (meals == null) return [];
      return (meals as List)
          .map((e) => Meal.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Không thể tìm kiếm: ${response.statusCode}');
  }
}
