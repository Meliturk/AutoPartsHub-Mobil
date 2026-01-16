import 'json_utils.dart';

class OrderItem {
  const OrderItem({
    required this.partId,
    required this.partName,
    required this.quantity,
    required this.unitPrice,
    this.imageUrl,
  });

  final int partId;
  final String partName;
  final int quantity;
  final double unitPrice;
  final String? imageUrl;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      partId: jsonToInt(json['partId']),
      partName: jsonToString(json['partName']),
      quantity: jsonToInt(json['quantity']),
      unitPrice: jsonToDouble(json['unitPrice']),
      imageUrl: jsonToUrl(json['imageUrl']),
    );
  }
}

class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.total,
    required this.customerName,
    required this.email,
    required this.address,
    required this.items,
    this.city,
    this.phone,
  });

  final int id;
  final DateTime createdAt;
  final String status;
  final double total;
  final String customerName;
  final String email;
  final String address;
  final String? city;
  final String? phone;
  final List<OrderItem> items;

  factory Order.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(OrderItem.fromJson)
        .toList();

    return Order(
      id: jsonToInt(json['id']),
      createdAt: jsonToDateTime(json['createdAt']),
      status: jsonToString(json['status']),
      total: jsonToDouble(json['total']),
      customerName: jsonToString(json['customerName']),
      email: jsonToString(json['email']),
      address: jsonToString(json['address']),
      city: json['city']?.toString(),
      phone: json['phone']?.toString(),
      items: items,
    );
  }
}
