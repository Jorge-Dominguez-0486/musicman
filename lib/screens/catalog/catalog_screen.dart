import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:musicman/providers/product_provider.dart';
import 'package:musicman/providers/cart_provider.dart';
import 'package:musicman/models/cart_item_model.dart';
import 'package:musicman/widgets/product_card.dart';
import 'package:musicman/widgets/empty_state_widget.dart';
import 'package:musicman/widgets/loading_widget.dart';
import 'package:musicman/core/theme/app_theme.dart';
import 'package:musicman/screens/home/main_scaffold.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getCategories(List products) {
    final cats = products.map((p) => p.category.toString()).toSet().toList();
    cats.sort();
    return cats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.secondaryColor.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          var products = provider.products.where((p) => p.isActive).toList();

          if (_selectedCategory.isNotEmpty) {
            products = products.where((p) => p.category == _selectedCategory).toList();
          }

          final query = _searchController.text.toLowerCase().trim();
          if (query.isNotEmpty) {
            products = products.where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query)
            ).toList();
          }

          final categories = _getCategories(provider.products);

          if (products.isEmpty) {
            return const EmptyStateWidget(
              message: 'Sin productos',
              icon: Icons.inventory_2_outlined,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (categories.isNotEmpty)
                SizedBox(
                  height: 44,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      ChoiceChip(
                        label: const Text('Todos'),
                        selected: _selectedCategory.isEmpty,
                        onSelected: (_) => setState(() => _selectedCategory = ''),
                        selectedColor: AppTheme.accentColor,
                        backgroundColor: AppTheme.secondaryColor,
                        labelStyle: TextStyle(color: _selectedCategory.isEmpty ? Colors.white : Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      ...categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: _selectedCategory == cat,
                              onSelected: (_) => setState(() => _selectedCategory = cat),
                              selectedColor: AppTheme.accentColor,
                              backgroundColor: AppTheme.secondaryColor,
                              labelStyle: TextStyle(color: _selectedCategory == cat ? Colors.white : Colors.white70),
                            ),
                          )),
                    ],
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push('/product/${product.id}'),
                      onAddToCart: () {
                        context.read<CartProvider>().addItem(
                          CartItemModel(
                            productId: product.id,
                            productName: product.name,
                            price: product.price,
                            quantity: 1,
                            imageUrl: product.imageUrl,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} agregado al carrito'),
                            backgroundColor: AppTheme.accentColor,
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'Ir al carrito →',
                              textColor: Colors.yellowAccent,
                              onPressed: () => MainScaffold.tabController.value = 2,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}
