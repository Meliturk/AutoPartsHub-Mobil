import 'json_utils.dart';
import 'vehicle.dart';

class PartsFilterMeta {
  const PartsFilterMeta({
    required this.categories,
    required this.partBrands,
    required this.vehicles,
    required this.minPrice,
    required this.maxPrice,
  });

  final List<String> categories;
  final List<String> partBrands;
  final List<Vehicle> vehicles;
  final double minPrice;
  final double maxPrice;

  factory PartsFilterMeta.fromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final partBrands = (json['partBrands'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final vehicles = (json['vehicles'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Vehicle.fromJson)
        .toList();

    return PartsFilterMeta(
      categories: categories,
      partBrands: partBrands,
      vehicles: vehicles,
      minPrice: jsonToDouble(json['minPrice']),
      maxPrice: jsonToDouble(json['maxPrice']),
    );
  }
}
