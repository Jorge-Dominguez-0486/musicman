import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicman/providers/product_provider.dart';
import 'package:musicman/models/product_model.dart';
import 'package:musicman/widgets/custom_text_field.dart';
import 'package:musicman/widgets/custom_button.dart';
import 'package:musicman/widgets/loading_widget.dart';
import 'package:musicman/widgets/empty_state_widget.dart';
import 'package:musicman/services/cloudinary_service.dart';
import 'package:musicman/core/theme/app_theme.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  void _showEditSheet(ProductModel product) {
    final nameController = TextEditingController(text: product.name);
    final descController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    final stockController = TextEditingController(text: product.stock.toString());
    final categoryController = TextEditingController(text: product.category);
    final imageController = TextEditingController(text: product.imageUrl);
    bool isActive = product.isActive;
    var isUploading = false;
    var imagePreviewUrl = product.imageUrl;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Editar Producto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                CustomTextField(label: 'Nombre', controller: nameController),
                const SizedBox(height: 12),
                CustomTextField(label: 'Descripción', controller: descController, maxLines: 3),
                const SizedBox(height: 12),
                CustomTextField(label: 'Precio', controller: priceController, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                CustomTextField(label: 'Stock', controller: stockController, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                CustomTextField(label: 'Categoría', controller: categoryController),
                const SizedBox(height: 12),
                if (isUploading)
                  const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                else ...[
                  if (imagePreviewUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imagePreviewUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (file == null) return;
                        setSheetState(() => isUploading = true);
                        final url = await CloudinaryService.uploadImage(file);
                        if (url != null && ctx.mounted) {
                          setSheetState(() {
                            imageController.text = url;
                            imagePreviewUrl = url;
                            isUploading = false;
                          });
                        } else if (ctx.mounted) {
                          setSheetState(() => isUploading = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Error al subir imagen'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      icon: const Icon(Icons.image, size: 18),
                      label: const Text('Seleccionar imagen'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  if (imageController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(imageController.text, style: const TextStyle(fontSize: 11, color: Colors.white38), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Activo', style: TextStyle(color: Colors.white70)),
                    const Spacer(),
                    Switch(
                      value: isActive,
                      onChanged: (v) => setSheetState(() => isActive = v),
                      activeColor: AppTheme.accentColor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Guardar',
                  onPressed: () {
                    context.read<ProductProvider>().updateProduct(product.id, {
                      'name': nameController.text.trim(),
                      'description': descController.text.trim(),
                      'price': double.tryParse(priceController.text) ?? product.price,
                      'stock': int.tryParse(stockController.text) ?? product.stock,
                      'category': categoryController.text.trim(),
                      'imageUrl': imageController.text.trim(),
                      'isActive': isActive,
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryColor,
        title: const Text('Eliminar Producto', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar $name?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<ProductProvider>().deleteProduct(id);
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
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final categoryController = TextEditingController();
    final imageController = TextEditingController();
    var isUploading = false;
    var imagePreviewUrl = '';

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Agregar Producto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                CustomTextField(label: 'Nombre', controller: nameController),
                const SizedBox(height: 12),
                CustomTextField(label: 'Descripción', controller: descController, maxLines: 3),
                const SizedBox(height: 12),
                CustomTextField(label: 'Precio', controller: priceController, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                CustomTextField(label: 'Stock', controller: stockController, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                CustomTextField(label: 'Categoría', controller: categoryController),
                const SizedBox(height: 12),
                if (isUploading)
                  const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                else ...[
                  if (imagePreviewUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imagePreviewUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (file == null) return;
                        setSheetState(() => isUploading = true);
                        final url = await CloudinaryService.uploadImage(file);
                        if (url != null && ctx.mounted) {
                          setSheetState(() {
                            imageController.text = url;
                            imagePreviewUrl = url;
                            isUploading = false;
                          });
                        } else if (ctx.mounted) {
                          setSheetState(() => isUploading = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Error al subir imagen'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      icon: const Icon(Icons.image, size: 18),
                      label: const Text('Seleccionar imagen'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Crear',
                  onPressed: () async {
                    await context.read<ProductProvider>().addProduct(
                      name: nameController.text.trim(),
                      description: descController.text.trim(),
                      price: double.tryParse(priceController.text) ?? 0,
                      stock: int.tryParse(stockController.text) ?? 0,
                      category: categoryController.text.trim(),
                      imageUrl: imageController.text.trim(),
                      isActive: true,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingWidget();
        }

        return Scaffold(
          body: provider.products.isEmpty
              ? const EmptyStateWidget(message: 'Sin productos', icon: Icons.inventory_2_outlined)
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                              width: 56,
                              height: 56,
                              child: product.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: product.imageUrl,
                                      width: 56,
                                      height: 56,
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
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                                const SizedBox(height: 2),
                                Text('\$${product.price.toStringAsFixed(2)} - Stock: ${product.stock}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white54),
                            onPressed: () => _showEditSheet(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _showDeleteDialog(product.id, product.name),
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
