import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/restaurant.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'restaurant_detail_screen.dart';
import '../../utils/constants.dart';

class RestaurantsTab extends StatefulWidget {
  const RestaurantsTab({super.key});

  @override
  State<RestaurantsTab> createState() => _RestaurantsTabState();
}

class _RestaurantsTabState extends State<RestaurantsTab>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<RestaurantProvider>();
      if (p.state == RestaurantLoadingState.idle) {
        p.fetchRestaurants();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFavorite(Restaurant r) {
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
    if (favProv.isFavorite(r.id)) {
      final fav = favProv.getFavorite(r.id);
      if (fav != null) {
        favProv.removeFavorite(fav.itemId).then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Đã xóa khỏi yêu thích'),
                  duration: Duration(seconds: 2)),
            );
          }
        }).catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Lỗi: ${favProv.errorMessage}\nHãy kiểm tra Firebase Rules'),
                  duration: Duration(seconds: 3)),
            );
          }
        });
      }
    } else {
      favProv
          .addFavorite(
            userId: auth.user!.uid,
            itemId: r.id,
            itemType: AppConstants.typeRestaurant,
            itemName: r.name,
            itemImageUrl: r.imageUrl,
          )
          .then((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Đã thêm vào yêu thích'),
                    duration: Duration(seconds: 2)),
              );
            }
          })
          .catchError((e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Lỗi: ${favProv.errorMessage}\nHãy kiểm tra Firebase Rules'),
                    duration: Duration(seconds: 3)),
              );
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<RestaurantProvider>();
    final favProv = context.watch<FavoritesProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm nhà hàng...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.search('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: provider.search,
          ),
        ),
        Expanded(child: _buildBody(provider, favProv)),
      ],
    );
  }

  Widget _buildBody(RestaurantProvider provider, FavoritesProvider favProv) {
    switch (provider.state) {
      case RestaurantLoadingState.loading:
        return const LoadingWidget(message: 'Đang tải...');
      case RestaurantLoadingState.error:
        return AppErrorWidget(
          message: provider.errorMessage,
          onRetry: provider.retry,
        );
      case RestaurantLoadingState.success:
        if (provider.restaurants.isEmpty) {
          return const Center(child: Text('Không tìm thấy nhà hàng nào.'));
        }
        return RefreshIndicator(
          onRefresh: provider.fetchRestaurants,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: provider.restaurants.length,
            itemBuilder: (_, i) {
              final r = provider.restaurants[i];
              return RestaurantCard(
                restaurant: r,
                isFavorite: favProv.isFavorite(r.id),
                onFavorite: () => _onFavorite(r),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantDetailScreen(restaurant: r),
                  ),
                ),
              );
            },
          ),
        );
      case RestaurantLoadingState.idle:
        return const SizedBox.shrink();
    }
  }
}
