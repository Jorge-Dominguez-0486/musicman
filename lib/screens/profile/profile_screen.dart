import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:musicman/providers/auth_provider.dart';
import 'package:musicman/services/order_service.dart';
import 'package:musicman/services/user_service.dart';
import 'package:musicman/models/order_model.dart';
import 'package:musicman/widgets/custom_text_field.dart';
import 'package:musicman/widgets/custom_button.dart';
import 'package:musicman/widgets/loading_widget.dart';
import 'package:musicman/core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static void reloadOrders() => _ProfileScreenState._reloadStatic();

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static _ProfileScreenState? _instance;

  List<OrderModel> _orders = [];
  bool _loadingOrders = true;

  @override
  void initState() {
    super.initState();
    _instance = this;
    _loadOrders();
  }

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }

  static void _reloadStatic() {
    _instance?._loadOrders();
  }

  Future<void> _loadOrders() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    setState(() => _loadingOrders = true);

    final orders = await OrderService().getUserOrders(auth.currentUser!.uid);
    if (mounted) {
      setState(() {
        _orders = orders;
        _loadingOrders = false;
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

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  void _showEditProfileSheet() {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Editar Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Nombre',
              controller: nameController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Teléfono',
              controller: phoneController,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Guardar',
              onPressed: () async {
                await UserService().updateUser(user.uid, {
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                });
                await auth.checkAuthState();
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.accentColor,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(user.email, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ),
              if (user.phone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Center(
                  child: Text(user.phone, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showEditProfileSheet,
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentColor,
                    side: const BorderSide(color: AppTheme.accentColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Mis Pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            if (_loadingOrders)
              const LoadingWidget()
            else if (_orders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No tienes pedidos aún', style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              ..._orders.map((order) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd/MM/yyyy').format(order.createdAt),
                                style: const TextStyle(fontSize: 12, color: Colors.white54),
                              ),
                              Text(
                                '\$${order.total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14, color: AppTheme.accentColor),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(
                            _statusLabel(order.status),
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          backgroundColor: _statusColor(order.status),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  )),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Cerrar sesión',
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              backgroundColor: Colors.redAccent,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
