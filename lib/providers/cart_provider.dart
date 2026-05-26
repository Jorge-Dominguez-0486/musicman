import 'package:flutter/foundation.dart';
import 'package:musicman/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  double get total {
    double sum = 0;
    for (final item in _items) {
      sum += item.price * item.quantity;
    }
    return sum;
  }

  void addItem(CartItemModel item) {
    final index = _items.indexWhere((i) => i.productId == item.productId);
    if (index != -1) {
      final existing = _items[index];
      _items[index] = CartItemModel(
        productId: existing.productId,
        productName: existing.productName,
        price: existing.price,
        quantity: existing.quantity + item.quantity,
        imageUrl: existing.imageUrl,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int qty) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (qty <= 0) {
        _items.removeAt(index);
      } else {
        final item = _items[index];
        _items[index] = CartItemModel(
          productId: item.productId,
          productName: item.productName,
          price: item.price,
          quantity: qty,
          imageUrl: item.imageUrl,
        );
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
