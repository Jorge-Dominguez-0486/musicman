import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:musicman/providers/cart_provider.dart';
import 'package:musicman/providers/auth_provider.dart';
import 'package:musicman/services/order_service.dart';
import 'package:musicman/models/order_model.dart';
import 'package:musicman/widgets/empty_state_widget.dart';
import 'package:musicman/screens/profile/profile_screen.dart';
import 'package:musicman/screens/home/main_scaffold.dart';
import 'package:musicman/core/theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const EmptyStateWidget(
              message: 'Tu carrito está vacío',
              icon: Icons.shopping_cart_outlined,
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemTile(item: item);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => MainScaffold.tabController.value = 1,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Seguir comprando'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total: \$${cart.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showOrderDialog(context, cart),
                        child: const Text('Realizar Pedido'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showOrderDialog(BuildContext context, CartProvider cart) {
    final addressController = TextEditingController();
    var isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.secondaryColor,
          title: Text(isLoading ? 'Procesando...' : 'Confirmar Pedido', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.accentColor)),
                )
              else ...[
                const Text('Dirección de entrega:', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu dirección',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: \$${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                ),
              ],
            ],
          ),
          actions: isLoading
              ? []
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (addressController.text.trim().isEmpty) return;

                      setDialogState(() => isLoading = true);

                      final auth = context.read<AuthProvider>();
                      final order = OrderModel(
                        id: const Uuid().v4(),
                        userId: auth.currentUser!.uid,
                        items: cart.items
                            .map((item) => {
                                  'productId': item.productId,
                                  'productName': item.productName,
                                  'price': item.price,
                                  'quantity': item.quantity,
                                  'imageUrl': item.imageUrl,
                                })
                            .toList(),
                        total: cart.total,
                        status: 'pending',
                        createdAt: DateTime.now(),
                        address: addressController.text.trim(),
                      );

                      await OrderService().createOrder(order);
                      cart.clearCart();

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ProfileScreen.reloadOrders();
                        MainScaffold.tabController.value = 3;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pedido realizado con éxito'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('Confirmar'),
                  ),
                ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final dynamic item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 64,
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: AppTheme.secondaryColor,
                          highlightColor: AppTheme.backgroundColor,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.backgroundColor,
                          child: const Icon(Icons.image_not_supported, color: Colors.white38),
                        ),
                      )
                    : Container(
                        color: AppTheme.backgroundColor,
                        child: const Icon(Icons.music_note, color: Colors.white38),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, color: AppTheme.accentColor),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onTap: () => context.read<CartProvider>().updateQuantity(item.productId, item.quantity - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('${item.quantity}', style: const TextStyle(color: Colors.white)),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onTap: () => context.read<CartProvider>().updateQuantity(item.productId, item.quantity + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => context.read<CartProvider>().removeItem(item.productId),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}
