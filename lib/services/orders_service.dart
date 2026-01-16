import '../models/cart_item.dart';
import '../models/order.dart';
import 'api_client.dart';

class OrdersService {
  OrdersService(this._api);

  final ApiClient _api;

  Future<Order> createOrder({
    required String token,
    required String customerName,
    required String email,
    required String address,
    String? city,
    String? phone,
    required List<CartItem> items,
  }) async {
    final payload = {
      'customerName': customerName,
      'email': email,
      'address': address,
      'city': city,
      'phone': phone,
      'items': items
          .map((item) => {'partId': item.partId, 'quantity': item.quantity})
          .toList(),
    };

    final data = await _api.postMap('/api/orders', payload, token: token);
    return Order.fromJson(data);
  }

  Future<List<Order>> getMyOrders(String token) async {
    final data = await _api.getList('/api/orders/my', token: token);
    return data
        .whereType<Map<String, dynamic>>()
        .map(Order.fromJson)
        .toList();
  }

  Future<Order> getOrder(String token, int id) async {
    final data = await _api.getMap('/api/orders/$id', token: token);
    return Order.fromJson(data);
  }
}
