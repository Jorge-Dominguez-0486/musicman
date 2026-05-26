import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musicman/core/constants/app_constants.dart';
import 'package:musicman/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection(AppConstants.categoriesCollection).get();
      return snapshot.docs.map((doc) => CategoryModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error en getCategories: $e');
      return [];
    }
  }

  Future<void> addCategory(CategoryModel cat) async {
    try {
      await _firestore.collection(AppConstants.categoriesCollection).doc(cat.id).set(cat.toMap());
    } catch (e) {
      print('Error en addCategory: $e');
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(AppConstants.categoriesCollection).doc(id).update(data);
    } catch (e) {
      print('Error en updateCategory: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection(AppConstants.categoriesCollection).doc(id).delete();
    } catch (e) {
      print('Error en deleteCategory: $e');
    }
  }
}
