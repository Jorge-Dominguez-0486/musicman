import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musicman/providers/category_provider.dart';
import 'package:musicman/models/category_model.dart';
import 'package:musicman/widgets/custom_text_field.dart';
import 'package:musicman/widgets/custom_button.dart';
import 'package:musicman/widgets/loading_widget.dart';
import 'package:musicman/core/theme/app_theme.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  void _showEditSheet(CategoryModel cat) {
    final nameController = TextEditingController(text: cat.name);

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
            const Text('Editar Categoría', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Nombre', controller: nameController),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Guardar',
              onPressed: () {
                context.read<CategoryProvider>().updateCategory(cat.id, {
                  'name': nameController.text.trim(),
                });
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(CategoryModel cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: const Text('Eliminar Categoría', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar la categoría ${cat.name}?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(cat.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    bool isActive = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.secondaryColor,
          title: const Text('Nueva Categoría', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: AppTheme.secondaryColor.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Activo', style: TextStyle(color: Colors.white70)),
                  const Spacer(),
                  Switch(
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v),
                    activeColor: AppTheme.accentColor,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  context.read<CategoryProvider>().addCategory(
                    name: nameController.text.trim(),
                    iconName: '',
                    isActive: isActive,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.categories.isEmpty) {
          return const LoadingWidget();
        }

        return Scaffold(
          body: provider.categories.isEmpty
              ? const Center(
                  child: Text('Sin categorías registradas', style: TextStyle(color: Colors.white54)),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final cat = provider.categories[index];

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
                                Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(
                                    cat.isActive ? 'Activo' : 'Inactivo',
                                    style: const TextStyle(fontSize: 11, color: Colors.white),
                                  ),
                                  backgroundColor: cat.isActive ? Colors.greenAccent : Colors.grey,
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
                                  _showEditSheet(cat);
                                  break;
                                case 'toggle':
                                  provider.updateCategory(cat.id, {'isActive': !cat.isActive});
                                  break;
                                case 'delete':
                                  _showDeleteDialog(cat);
                                  break;
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Editar'))),
                              PopupMenuItem(
                                value: 'toggle',
                                child: ListTile(
                                  leading: Icon(cat.isActive ? Icons.visibility_off : Icons.visibility),
                                  title: Text(cat.isActive ? 'Desactivar' : 'Activar'),
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
            onPressed: _showAddDialog,
            backgroundColor: AppTheme.accentColor,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
