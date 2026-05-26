import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:musicman/models/category_model.dart';
import 'package:musicman/services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final Uuid _uuid = const Uuid();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _categoryService.getCategories();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory({
    required String name,
    required String iconName,
    required bool isActive,
  }) async {
    _isLoading = true;
    notifyListeners();

    final cat = CategoryModel(
      id: _uuid.v4(),
      name: name,
      iconName: iconName,
      isActive: isActive,
    );

    await _categoryService.addCategory(cat);
    _categories.add(cat);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _categoryService.updateCategory(id, data);

    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _categories[index] = CategoryModel.fromMap(
        {..._categories[index].toMap(), ...data},
        id,
      );
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    await _categoryService.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
