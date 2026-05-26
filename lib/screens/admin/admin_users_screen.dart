import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:musicman/providers/user_provider.dart';
import 'package:musicman/services/user_service.dart';
import 'package:musicman/models/user_model.dart';
import 'package:musicman/widgets/custom_text_field.dart';
import 'package:musicman/widgets/custom_button.dart';
import 'package:musicman/widgets/loading_widget.dart';
import 'package:musicman/widgets/empty_state_widget.dart';
import 'package:musicman/core/theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUsers();
    });
  }

  void _showEditSheet(UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Editar Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Nombre', controller: nameController),
            const SizedBox(height: 12),
            CustomTextField(label: 'Email', controller: emailController),
            const SizedBox(height: 12),
            CustomTextField(label: 'Teléfono', controller: phoneController),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Guardar',
              onPressed: () {
                context.read<UserProvider>().updateUser(user.uid, {
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                });
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String uid, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: const Text('Eliminar Usuario', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar a $name?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<UserProvider>().deleteUser(uid);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddSheet() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'client';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Agregar Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              CustomTextField(label: 'Nombre', controller: nameController),
              const SizedBox(height: 12),
              CustomTextField(label: 'Email', controller: emailController),
              const SizedBox(height: 12),
              CustomTextField(label: 'Teléfono', controller: phoneController),
              const SizedBox(height: 12),
              CustomTextField(label: 'Contraseña', controller: passwordController, obscureText: true),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: AppTheme.backgroundColor,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Rol',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: AppTheme.secondaryColor.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'client', child: Text('Cliente')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setSheetState(() => selectedRole = v!),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Crear',
                onPressed: () async {
                  final uid = const Uuid().v4();
                  final user = UserModel(
                    uid: uid,
                    email: emailController.text.trim(),
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    role: selectedRole,
                    createdAt: DateTime.now(),
                    isActive: true,
                  );
                  await UserService().createUser(user);
                  context.read<UserProvider>().loadUsers();
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
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingWidget();
        }

        return Scaffold(
          body: provider.users.isEmpty
              ? const EmptyStateWidget(message: 'Sin usuarios', icon: Icons.people_outlined)
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.users.length,
                  itemBuilder: (context, index) {
                    final user = provider.users[index];
                    final isAdmin = user.role == 'admin';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                                Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                                const SizedBox(height: 2),
                                Text(user.email, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(
                                    isAdmin ? 'Admin' : 'Cliente',
                                    style: const TextStyle(fontSize: 11, color: Colors.white),
                                  ),
                                  backgroundColor: isAdmin ? Colors.redAccent : Colors.blueAccent,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white54),
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _showEditSheet(user);
                                  break;
                                case 'toggle':
                                  provider.toggleAdmin(user.uid, !isAdmin);
                                  break;
                                case 'delete':
                                  _showDeleteDialog(user.uid, user.name);
                                  break;
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Editar'))),
                              PopupMenuItem(
                                value: 'toggle',
                                child: ListTile(
                                  leading: Icon(isAdmin ? Icons.person : Icons.admin_panel_settings),
                                  title: Text(isAdmin ? 'Hacer cliente' : 'Hacer admin'),
                                ),
                              ),
                              const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.redAccent), title: Text('Eliminar'))),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddSheet,
            backgroundColor: AppTheme.accentColor,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
