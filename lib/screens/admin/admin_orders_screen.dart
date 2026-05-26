import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:musicman/services/order_service.dart';
import 'package:musicman/services/user_service.dart';
import 'package:musicman/models/order_model.dart';
import 'package:musicman/models/user_model.dart';
import 'package:musicman/widgets/loading_widget.dart';
import 'package:musicman/widgets/empty_state_widget.dart';
import 'package:musicman/core/theme/app_theme.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<OrderModel> _orders = [];
  Map<String, UserModel?> _userCache = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);

    final orders = await OrderService().getAllOrders();

    for (final order in orders) {
      if (!_userCache.containsKey(order.userId)) {
        _userCache[order.userId] = await UserService().getUser(order.userId);
      }
    }

    if (mounted) {
      setState(() {
        _orders = orders;
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orangeAccent;
      case 'confirmed':
        return Colors.blueAccent;
      case 'delivered':
        return Colors.greenAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget();
    }

    if (_orders.isEmpty) {
      return const EmptyStateWidget(message: 'Sin pedidos', icon: Icons.receipt_outlined);
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final userName = _userCache[order.userId]?.name ?? 'Usuario';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(userName, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                    const Spacer(),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                    ),
                  ],
                ),
                if (order.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(order.address, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: order.status,
                  dropdownColor: AppTheme.backgroundColor,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _statusColor(order.status).withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmado')),
                    DropdownMenuItem(value: 'delivered', child: Text('Entregado')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')),
                  ],
                  onChanged: (newStatus) async {
                    if (newStatus != null && newStatus != order.status) {
                      await OrderService().updateOrderStatus(order.id, newStatus);
                      setState(() {
                        final idx = _orders.indexWhere((o) => o.id == order.id);
                        if (idx != -1) {
                          _orders[idx] = OrderModel(
                            id: order.id,
                            userId: order.userId,
                            items: order.items,
                            total: order.total,
                            status: newStatus,
                            createdAt: order.createdAt,
                            address: order.address,
                          );
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
