import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../utils/constants.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favProv = context.watch<FavoritesProvider>();
    final isFav = favProv.isFavorite(restaurant.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF00B14F),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                restaurant.name,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: restaurant.imageUrl.isNotEmpty
                  ? Image.network(
                      restaurant.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFB9F0CB),
                        child: const Icon(Icons.restaurant,
                            size: 80, color: const Color(0xFF00B14F)),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFB9F0CB),
                      child: const Icon(Icons.restaurant,
                          size: 80, color: const Color(0xFF00B14F)),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (!auth.isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Đăng nhập để lưu yêu thích!')),
                    );
                    return;
                  }
                  if (isFav) {
                    final fav = favProv.getFavorite(restaurant.id);
                    if (fav != null) favProv.removeFavorite(fav.id);
                  } else {
                    favProv.addFavorite(
                      userId: auth.user!.uid,
                      itemId: restaurant.id,
                      itemType: AppConstants.typeRestaurant,
                      itemName: restaurant.name,
                      itemImageUrl: restaurant.imageUrl,
                    );
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.star, Colors.amber,
                      'Đánh giá: ${restaurant.rating.toStringAsFixed(1)} / 5.0'),
                  const SizedBox(height: 8),
                  _infoRow(
                      Icons.category, const Color(0xFF00B14F), restaurant.category),
                  const SizedBox(height: 8),
                  _infoRow(Icons.restaurant_menu, Colors.teal,
                      'Ẩm thực: ${restaurant.cuisine}'),
                  const SizedBox(height: 8),
                  _infoRow(
                      Icons.location_on, Colors.red, restaurant.address),
                  const SizedBox(height: 8),
                  _infoRow(
                      Icons.phone, Colors.green, restaurant.phone),
                  const SizedBox(height: 8),
                  _infoRow(Icons.access_time, Colors.blue,
                      'Giờ mở cửa: ${restaurant.openTime}'),
                  const Divider(height: 32),
                  if (restaurant.description.isNotEmpty) ...[
                    const Text(
                      'Giới thiệu',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      restaurant.description,
                      style: const TextStyle(
                          fontSize: 15, color: Colors.black87, height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }
}
