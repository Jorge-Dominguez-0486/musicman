import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:musicman/providers/product_provider.dart';
import 'package:musicman/providers/cart_provider.dart';
import 'package:musicman/models/cart_item_model.dart';
import 'package:musicman/widgets/custom_button.dart';
import 'package:musicman/core/theme/app_theme.dart';
import 'package:musicman/screens/home/main_scaffold.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final products = provider.products.where((p) => p.id == widget.productId);
        if (products.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Producto')),
            body: const Center(
              child: Text('Producto no encontrado', style: TextStyle(color: Colors.white54)),
            ),
          );
        }

        final product = products.first;

        return Scaffold(
          appBar: AppBar(title: Text(product.name)),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: product.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: AppTheme.secondaryColor,
                            highlightColor: AppTheme.backgroundColor,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.backgroundColor,
                            child: const Icon(Icons.image_not_supported, size: 48, color: Colors.white38),
                          ),
                        )
                      : Container(
                          color: AppTheme.backgroundColor,
                          child: const Icon(Icons.music_note, size: 48, color: Colors.white38),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.inventory_2, size: 16, color: product.stock > 0 ? Colors.greenAccent : Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(
                            product.stock > 0 ? '${product.stock} disponibles' : 'Sin stock',
                            style: TextStyle(
                              fontSize: 14,
                              color: product.stock > 0 ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Descripción',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description.isNotEmpty ? product.description : 'Sin descripción',
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      if (product.stock > 0) ...[
                        const SizedBox(height: 24),
                        const Text('Cantidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: AppTheme.accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                icon: const Icon(Icons.remove),
                                color: Colors.white,
                                disabledColor: Colors.white38,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '$_quantity',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: const BoxDecoration(
                                color: AppTheme.accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _quantity < product.stock ? () => setState(() => _quantity++) : null,
                                icon: const Icon(Icons.add),
                                color: Colors.white,
                                disabledColor: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      CustomButton(
                        text: product.stock > 0 ? 'Agregar al carrito' : 'Sin stock',
                        onPressed: product.stock > 0
                            ? () {
                                context.read<CartProvider>().addItem(
                                  CartItemModel(
                                    productId: product.id,
                                    productName: product.name,
                                    price: product.price,
                                    quantity: _quantity,
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
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
