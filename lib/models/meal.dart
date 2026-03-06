class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnailUrl;
  final String tags;
  final String youtubeUrl;
  final List<String> ingredients;
  final List<String> measures;

  const Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnailUrl,
    required this.tags,
    required this.youtubeUrl,
    required this.ingredients,
    required this.measures,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final measures = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']?.toString() ?? '';
      final measure = json['strMeasure$i']?.toString() ?? '';
      if (ingredient.trim().isNotEmpty) {
        ingredients.add(ingredient.trim());
        measures.add(measure.trim());
      }
    }
    return Meal(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? 'Unknown',
      category: json['strCategory']?.toString() ?? '',
      area: json['strArea']?.toString() ?? '',
      instructions: json['strInstructions']?.toString() ?? '',
      thumbnailUrl: json['strMealThumb']?.toString() ?? '',
      tags: json['strTags']?.toString() ?? '',
      youtubeUrl: json['strYoutube']?.toString() ?? '',
      ingredients: ingredients,
      measures: measures,
    );
  }

  factory Meal.fromListJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? 'Unknown',
      category: json['strCategory']?.toString() ?? '',
      area: '',
      instructions: '',
      thumbnailUrl: json['strMealThumb']?.toString() ?? '',
      tags: '',
      youtubeUrl: '',
      ingredients: const [],
      measures: const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'idMeal': id,
        'strMeal': name,
        'strCategory': category,
        'strArea': area,
        'strInstructions': instructions,
        'strMealThumb': thumbnailUrl,
        'strTags': tags,
        'strYoutube': youtubeUrl,
      };
}
