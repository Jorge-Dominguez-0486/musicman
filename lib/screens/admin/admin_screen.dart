import 'package:flutter/material.dart';
import 'package:musicman/screens/admin/admin_users_screen.dart';
import 'package:musicman/screens/admin/admin_products_screen.dart';
import 'package:musicman/screens/admin/admin_orders_screen.dart';
import 'package:musicman/screens/admin/admin_categories_screen.dart';
import 'package:musicman/core/theme/app_theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Administración'),
          bottom: const TabBar(
            indicatorColor: AppTheme.accentColor,
            labelColor: AppTheme.accentColor,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.people_outlined), text: 'Usuarios'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Productos'),
              Tab(icon: Icon(Icons.receipt_outlined), text: 'Pedidos'),
              Tab(icon: Icon(Icons.category_outlined), text: 'Categorías'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminUsersScreen(),
            AdminProductsScreen(),
            AdminOrdersScreen(),
            AdminCategoriesScreen(),
          ],
        ),
      ),
    );
  }
}
