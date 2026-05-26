import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double total;
  final String status;
  final DateTime createdAt;
  final String address;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.address,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      total: (map['total'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      address: map['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'total': total,
      'status': status,
      'createdAt': createdAt,
      'address': address,
    };
  }
}
