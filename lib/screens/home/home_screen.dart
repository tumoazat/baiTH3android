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
              icon: const Icon(Icons.logout),
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
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: 'Restaurants'),
            Tab(icon: Icon(Icons.ramen_dining), text: 'Meals'),
            Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
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
