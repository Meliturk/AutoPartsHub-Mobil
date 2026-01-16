import 'json_utils.dart';
import 'order.dart';

class SellerDashboard {
  const SellerDashboard({
    required this.dayTotal,
    required this.weekTotal,
    required this.monthTotal,
    required this.partsCount,
    required this.ordersCount,
    required this.chartPoints,
    required this.productSales,
  });

  final double dayTotal;
  final double weekTotal;
  final double monthTotal;
  final int partsCount;
  final int ordersCount;
  final List<SellerChartPoint> chartPoints;
  final List<SellerProductSales> productSales;

  factory SellerDashboard.fromJson(Map<String, dynamic> json) {
    final chartPoints = (json['chartPoints'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(SellerChartPoint.fromJson)
        .toList();
    
    final productSales = (json['productSales'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(SellerProductSales.fromJson)
        .toList();

    return SellerDashboard(
      dayTotal: jsonToDouble(json['dayTotal']),
      weekTotal: jsonToDouble(json['weekTotal']),
      monthTotal: jsonToDouble(json['monthTotal']),
      partsCount: jsonToInt(json['partsCount']),
      ordersCount: jsonToInt(json['ordersCount']),
      chartPoints: chartPoints,
      productSales: productSales,
    );
  }
}

class SellerChartPoint {
  const SellerChartPoint({
    required this.label,
    required this.total,
  });

  final String label;
  final double total;

  factory SellerChartPoint.fromJson(Map<String, dynamic> json) {
    return SellerChartPoint(
      label: jsonToString(json['label']),
      total: jsonToDouble(json['total']),
    );
  }
}

class SellerProductSales {
  const SellerProductSales({
    required this.partId,
    required this.name,
    required this.quantity,
    required this.total,
  });

  final int partId;
  final String name;
  final int quantity;
  final double total;

  factory SellerProductSales.fromJson(Map<String, dynamic> json) {
    return SellerProductSales(
      partId: jsonToInt(json['partId']),
      name: jsonToString(json['name']),
      quantity: jsonToInt(json['quantity']),
      total: jsonToDouble(json['total']),
    );
  }
}

class SellerQuestion {
  const SellerQuestion({
    required this.id,
    required this.question,
    required this.createdAt,
    required this.partId,
    required this.partName,
    this.answer,
    this.userName,
    this.answeredAt,
    this.imageUrl,
  });

  final int id;
  final String question;
  final DateTime createdAt;
  final int partId;
  final String partName;
  final String? answer;
  final String? userName;
  final DateTime? answeredAt;
  final String? imageUrl;

  factory SellerQuestion.fromJson(Map<String, dynamic> json) {
    return SellerQuestion(
      id: jsonToInt(json['id']),
      question: jsonToString(json['question']),
      createdAt: jsonToDateTime(json['createdAt']),
      partId: jsonToInt(json['partId'] ?? json['part']?['id'] ?? 0),
      partName: jsonToString(json['partName'] ?? json['part']?['name'] ?? ''),
      answer: json['answer']?.toString(),
      userName: json['userName']?.toString(),
      answeredAt: json['answeredAt'] == null ? null : jsonToDateTime(json['answeredAt']),
      imageUrl: jsonToUrl(json['imageUrl'] ?? json['partImageUrl'] ?? json['part']?['imageUrl']),
    );
  }
}

class SellerOrder {
  const SellerOrder({
    required this.orderId,
    required this.createdAt,
    required this.status,
    required this.customerName,
    required this.total,
    required this.items,
  });

  final int orderId;
  final DateTime createdAt;
  final String status;
  final String customerName;
  final double total;
  final List<OrderItem> items;

  factory SellerOrder.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(OrderItem.fromJson)
        .toList();

    return SellerOrder(
      orderId: jsonToInt(json['orderId']),
      createdAt: jsonToDateTime(json['createdAt']),
      status: jsonToString(json['status']),
      customerName: jsonToString(json['customerName']),
      total: jsonToDouble(json['total']),
      items: items,
    );
  }
}
