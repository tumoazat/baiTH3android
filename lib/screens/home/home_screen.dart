import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../restaurants/restaurants_tab.dart';
import '../meals/meals_tab.dart';
import '../favorites/favorites_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initFavorites();
  }

  void _initFavorites() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<FavoritesProvider>().listenToFavorites(user.uid);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          if (auth.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Đăng xuất',
              onPressed: () async {
                context.read<FavoritesProvider>().clear();
                await auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              },
            ),
          if (!auth.isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                icon: const Icon(Icons.login_rounded,
                    size: 16, color: Colors.white),
                label: const Text(
                  'Đăng nhập',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.storefront_rounded), text: 'Nhà hàng'),
            Tab(icon: Icon(Icons.ramen_dining_rounded), text: 'Món ăn'),
            Tab(icon: Icon(Icons.favorite_rounded), text: 'Yêu thích'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RestaurantsTab(),
          MealsTab(),
          FavoritesScreen(),
        ],
      ),
    );
  }
}
