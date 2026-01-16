import '../models/vehicle.dart';
import 'api_client.dart';

class VehiclesService {
  VehiclesService(this._api);

  final ApiClient _api;

  Future<List<Vehicle>> getVehicles() async {
    final data = await _api.getList('/api/vehicles');
    return data
        .whereType<Map<String, dynamic>>()
        .map(Vehicle.fromJson)
        .toList();
  }
}
