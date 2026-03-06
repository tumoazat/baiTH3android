import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/user_favorite.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import '../restaurants/restaurant_detail_screen.dart';
import '../meals/meal_detail_screen.dart';
import '../../models/restaurant.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favProv = context.watch<FavoritesProvider>();

    if (!auth.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Đăng nhập để xem danh sách yêu thích',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      );
    }

    switch (favProv.state) {
      case FavoritesLoadingState.loading:
        return const LoadingWidget(message: 'Đang tải...');

      case FavoritesLoadingState.error:
        return AppErrorWidget(
          message: favProv.errorMessage,
          onRetry: () => favProv.retry(auth.user!.uid),
        );

      case FavoritesLoadingState.success:
      case FavoritesLoadingState.idle:
        if (favProv.favorites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa có mục yêu thích nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Nhấn ❤️ để lưu nhà hàng hoặc món ăn yêu thích',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: favProv.favorites.length,
          itemBuilder: (_, i) {
            final fav = favProv.favorites[i];
            return _FavoriteItem(
              favorite: fav,
              onRemove: () => favProv.removeFavorite(fav.itemId),
            );
          },
        );
    }
  }
}

class _FavoriteItem extends StatelessWidget {
  final UserFavorite favorite;
  final VoidCallback onRemove;

  const _FavoriteItem({required this.favorite, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isRestaurant = favorite.itemType == AppConstants.typeRestaurant;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: favorite.itemImageUrl.isNotEmpty
              ? Image.network(
                  favorite.itemImageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: Icon(
                      isRestaurant
                          ? Icons.restaurant
                          : Icons.restaurant_menu,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: Icon(
                    isRestaurant ? Icons.restaurant : Icons.restaurant_menu,
                    color: Colors.grey,
                  ),
                ),
        ),
        title: Text(
          favorite.itemName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Icon(
              isRestaurant ? Icons.storefront : Icons.ramen_dining,
              size: 14,
              color: Colors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              isRestaurant ? 'Nhà hàng' : 'Món ăn',
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onRemove,
        ),
        onTap: () => _navigateToDetail(context),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    if (favorite.itemType == AppConstants.typeRestaurant) {
      final restaurant = Restaurant(
        id: favorite.itemId,
        name: favorite.itemName,
        rating: 0,
        category: '',
        address: '',
        imageUrl: favorite.itemImageUrl,
        cuisine: '',
        description: '',
        phone: '',
        openTime: '',
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MealDetailScreen(mealId: favorite.itemId),
        ),
      );
    }
  }
}
