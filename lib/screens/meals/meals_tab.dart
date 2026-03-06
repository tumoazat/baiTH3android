import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/meal.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'meal_detail_screen.dart';
import '../../utils/constants.dart';

class MealsTab extends StatefulWidget {
  const MealsTab({super.key});

  @override
  State<MealsTab> createState() => _MealsTabState();
}

class _MealsTabState extends State<MealsTab>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<MealProvider>();
      if (p.state == MealLoadingState.idle) {
        p.fetchCategories().then((_) {
          if (mounted) p.fetchMealsByCategory(p.selectedCategory);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFavorite(Meal meal) {
    final auth = context.read<AuthProvider>();
    final favProv = context.read<FavoritesProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đăng nhập để lưu yêu thích!'),
            duration: Duration(seconds: 2)),
      );
      return;
    }
    if (favProv.isFavorite(meal.id)) {
      final fav = favProv.getFavorite(meal.id);
      if (fav != null) favProv.removeFavorite(fav.id);
    } else {
      favProv.addFavorite(
        userId: auth.user!.uid,
        itemId: meal.id,
        itemType: AppConstants.typeMeal,
        itemName: meal.name,
        itemImageUrl: meal.thumbnailUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<MealProvider>();
    final favProv = context.watch<FavoritesProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm món ăn...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _isSearching = false);
                        provider.fetchMealsByCategory(provider.selectedCategory);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                setState(() => _isSearching = true);
                provider.searchMeals(v.trim());
              }
            },
          ),
        ),
        if (!_isSearching && provider.categories.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: provider.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = provider.categories[i];
                final selected = cat == provider.selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => provider.fetchMealsByCategory(cat),
                  selectedColor: Colors.orange,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 8),
        Expanded(child: _buildBody(provider, favProv)),
      ],
    );
  }

  Widget _buildBody(MealProvider provider, FavoritesProvider favProv) {
    switch (provider.state) {
      case MealLoadingState.loading:
        return const LoadingWidget(message: 'Đang tải...');
      case MealLoadingState.error:
        return AppErrorWidget(
          message: provider.errorMessage,
          onRetry: provider.retry,
        );
      case MealLoadingState.success:
        if (provider.meals.isEmpty) {
          return const Center(child: Text('Không tìm thấy món ăn nào.'));
        }
        return RefreshIndicator(
          onRefresh: provider.retry,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: provider.meals.length,
            itemBuilder: (_, i) {
              final m = provider.meals[i];
              return MealCard(
                meal: m,
                isFavorite: favProv.isFavorite(m.id),
                onFavorite: () => _onFavorite(m),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealDetailScreen(mealId: m.id),
                  ),
                ),
              );
            },
          ),
        );
      case MealLoadingState.idle:
        return const SizedBox.shrink();
    }
  }
}
