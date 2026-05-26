import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musicman/core/constants/app_constants.dart';
import 'package:musicman/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection(AppConstants.productsCollection).doc(product.id).set(product.toMap());
    } catch (e) {
      print('Error en addProduct: $e');
    }
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await _firestore.collection(AppConstants.productsCollection).get();
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error en getProducts: $e');
      return [];
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error en getProductsByCategory: $e');
      return [];
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(AppConstants.productsCollection).doc(id).update(data);
    } catch (e) {
      print('Error en updateProduct: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection(AppConstants.productsCollection).doc(id).delete();
    } catch (e) {
      print('Error en deleteProduct: $e');
    }
  }

  Stream<List<ProductModel>> productsStream() {
    return _firestore.collection(AppConstants.productsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
