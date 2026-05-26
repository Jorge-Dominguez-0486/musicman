import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:musicman/providers/auth_provider.dart';
import 'package:musicman/screens/home/home_screen.dart';
import 'package:musicman/screens/catalog/catalog_screen.dart';
import 'package:musicman/screens/cart/cart_screen.dart';
import 'package:musicman/screens/profile/profile_screen.dart';
import 'package:musicman/core/theme/app_theme.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  static final tabController = ValueNotifier<int>(0);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final List<Widget> _screens = const [
    HomeScreen(),
    CatalogScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    MainScaffold.tabController.value = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MainScaffold.tabController,
      builder: (context, _) {
        final i = MainScaffold.tabController.value;
        return _buildScaffold(i);
      },
    );
  }

  Widget _buildScaffold(int currentIndex) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          MainScaffold.tabController.value = index;
          if (index == 3) {
            Future.microtask(() => ProfileScreen.reloadOrders());
          }
        },
        backgroundColor: AppTheme.secondaryColor,
        selectedItemColor: AppTheme.accentColor,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => context.push('/admin'),
              backgroundColor: AppTheme.accentColor,
              child: const Icon(Icons.admin_panel_settings),
            )
          : null,
    );
  }
}
