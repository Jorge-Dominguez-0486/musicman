import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musicman/core/constants/app_constants.dart';
import 'package:musicman/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(OrderModel order) async {
    try {
      await _firestore.collection(AppConstants.ordersCollection).doc(order.id).set(order.toMap());
    } catch (e) {
      print('Error en createOrder: $e');
    }
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.ordersCollection)
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error en getUserOrders: $e');
      return [];
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _firestore.collection(AppConstants.ordersCollection).get();
      return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error en getAllOrders: $e');
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection(AppConstants.ordersCollection).doc(orderId).update({
        'status': status,
      });
    } catch (e) {
      print('Error en updateOrderStatus: $e');
    }
  }
}
