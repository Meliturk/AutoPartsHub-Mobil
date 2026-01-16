import 'json_utils.dart';
import 'vehicle.dart';

class PartImage {
  const PartImage({required this.id, required this.url, required this.sortOrder});

  final int id;
  final String url;
  final int sortOrder;

  factory PartImage.fromJson(Map<String, dynamic> json) {
    return PartImage(
      id: jsonToInt(json['id']),
      url: jsonToUrl(json['url']) ?? '',
      sortOrder: jsonToInt(json['sortOrder']),
    );
  }
}

class Question {
  const Question({
    required this.id,
    required this.question,
    required this.createdAt,
    this.answer,
    this.userName,
    this.answeredAt,
  });

  final int id;
  final String question;
  final String? answer;
  final String? userName;
  final DateTime createdAt;
  final DateTime? answeredAt;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: jsonToInt(json['id']),
      question: jsonToString(json['question']),
      answer: json['answer']?.toString(),
      userName: json['userName']?.toString(),
      createdAt: jsonToDateTime(json['createdAt']),
      answeredAt: json['answeredAt'] == null ? null : jsonToDateTime(json['answeredAt']),
    );
  }
}

class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.createdAt,
    this.comment,
    this.userName,
  });

  final int id;
  final int rating;
  final String? comment;
  final String? userName;
  final DateTime createdAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: jsonToInt(json['id']),
      rating: jsonToInt(json['rating']),
      comment: json['comment']?.toString(),
      userName: json['userName']?.toString(),
      createdAt: jsonToDateTime(json['createdAt']),
    );
  }
}

class PartListItem {
  const PartListItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.stock,
    required this.rating,
    required this.ratingCount,
    required this.vehicles,
    this.imageUrl,
    this.sellerName,
  });

  final int id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final int stock;
  final String? imageUrl;
  final double rating;
  final int ratingCount;
  final List<Vehicle> vehicles;
  final String? sellerName;

  factory PartListItem.fromJson(Map<String, dynamic> json) {
    final vehicles = (json['vehicles'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Vehicle.fromJson)
        .toList();

    return PartListItem(
      id: jsonToInt(json['id']),
      name: jsonToString(json['name']),
      brand: jsonToString(json['brand']),
      category: jsonToString(json['category']),
      price: jsonToDouble(json['price']),
      stock: jsonToInt(json['stock']),
      imageUrl: jsonToUrl(json['imageUrl']),
      rating: jsonToDouble(json['rating']),
      ratingCount: jsonToInt(json['ratingCount']),
      vehicles: vehicles,
      sellerName: json['sellerName']?.toString(),
    );
  }
}

class PartDetail {
  const PartDetail({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.stock,
    required this.rating,
    required this.ratingCount,
    required this.vehicles,
    required this.images,
    required this.questions,
    required this.reviews,
    this.description,
    this.imageUrl,
    this.sellerId,
    this.sellerName,
  });

  final int id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final int stock;
  final String? description;
  final String? imageUrl;
  final int? sellerId;
  final String? sellerName;
  final List<Vehicle> vehicles;
  final List<PartImage> images;
  final double rating;
  final int ratingCount;
  final List<Question> questions;
  final List<Review> reviews;

  factory PartDetail.fromJson(Map<String, dynamic> json) {
    final vehicles = (json['vehicles'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Vehicle.fromJson)
        .toList();
    final images = (json['images'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PartImage.fromJson)
        .toList();
    final questions = (json['questions'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Question.fromJson)
        .toList();
    final reviews = (json['reviews'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Review.fromJson)
        .toList();

    return PartDetail(
      id: jsonToInt(json['id']),
      name: jsonToString(json['name']),
      brand: jsonToString(json['brand']),
      category: jsonToString(json['category']),
      price: jsonToDouble(json['price']),
      stock: jsonToInt(json['stock']),
      description: json['description']?.toString(),
      imageUrl: jsonToUrl(json['imageUrl']),
      sellerId: json['sellerId'] == null ? null : jsonToInt(json['sellerId']),
      sellerName: json['sellerName']?.toString(),
      vehicles: vehicles,
      images: images,
      rating: jsonToDouble(json['rating']),
      ratingCount: jsonToInt(json['ratingCount']),
      questions: questions,
      reviews: reviews,
    );
  }
}
