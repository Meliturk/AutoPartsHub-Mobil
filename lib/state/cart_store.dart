import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';

class CartStore extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  void addItem(CartItem item) {
    final index = _items.indexWhere((e) => e.partId == item.partId);
    if (index >= 0) {
      final existing = _items[index];
      _items[index] = existing.copyWith(quantity: existing.quantity + item.quantity);
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void updateQuantity(int partId, int quantity) {
    final index = _items.indexWhere((e) => e.partId == partId);
    if (index < 0) return;
    final safeQty = quantity < 1 ? 1 : quantity;
    _items[index] = _items[index].copyWith(quantity: safeQty);
    notifyListeners();
  }

  void removeItem(int partId) {
    _items.removeWhere((e) => e.partId == partId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
