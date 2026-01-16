import 'json_utils.dart';

class Vehicle {
  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    this.engine,
    this.startYear,
    this.endYear,
    this.imageUrl,
    this.brandLogoUrl,
  });

  final int id;
  final String brand;
  final String model;
  final int year;
  final String? engine;
  final int? startYear;
  final int? endYear;
  final String? imageUrl;
  final String? brandLogoUrl;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: jsonToInt(json['id']),
      brand: jsonToString(json['brand']),
      model: jsonToString(json['model']),
      year: jsonToInt(json['year']),
      engine: json['engine']?.toString(),
      startYear: json['startYear'] == null ? null : jsonToInt(json['startYear']),
      endYear: json['endYear'] == null ? null : jsonToInt(json['endYear']),
      imageUrl: jsonToUrl(json['imageUrl']),
      brandLogoUrl: jsonToUrl(json['brandLogoUrl']),
    );
  }

  String get yearLabel {
    final start = startYear ?? year;
    final end = endYear ?? year;
    if (start == end) return start.toString();
    return '$start-$end';
  }
}
