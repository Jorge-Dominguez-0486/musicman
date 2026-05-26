import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:musicman/models/product_model.dart';
import 'package:musicman/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final Uuid _uuid = const Uuid();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _selectedCategory = '';

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  set selectedCategory(String category) {
    _selectedCategory = category;
    if (category.isEmpty) {
      loadProducts();
    } else {
      loadByCategory(category);
    }
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await _productService.getProducts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    _products = await _productService.getProductsByCategory(category);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required String imageUrl,
    required bool isActive,
  }) async {
    _isLoading = true;
    notifyListeners();

    final product = ProductModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      price: price,
      stock: stock,
      category: category,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: DateTime.now(),
    );

    await _productService.addProduct(product);
    _products.add(product);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _productService.updateProduct(id, data);

    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = ProductModel.fromMap(
        {..._products[index].toMap(), ...data, 'createdAt': _products[index].createdAt},
        id,
      );
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
