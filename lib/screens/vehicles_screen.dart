import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../services/vehicles_service.dart';
import '../widgets/empty_state.dart';
import 'parts_list_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  late Future<List<Vehicle>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Vehicle>> _load() {
    return context.read<VehiclesService>().getVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Araçlar')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<Vehicle>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return EmptyState(
                title: 'Hata',
                subtitle: 'Araçlar yüklenemedi',
                icon: Icons.error_outline,
                onRetry: () => setState(() => _future = _load()),
              );
            }

            final vehicles = snapshot.data!;
            if (vehicles.isEmpty) {
              return const EmptyState(
                title: 'Henüz araç yok',
                subtitle: 'Araç listesi boş',
                icon: Icons.directions_car,
              );
            }

            // Group by brand, then by model
            final brandGroups = <String, Map<String, List<Vehicle>>>{};
            final brandLogoMap = <String, String?>{};
            for (final vehicle in vehicles) {
              brandGroups.putIfAbsent(vehicle.brand, () => {});
              brandGroups[vehicle.brand]!.putIfAbsent(vehicle.model, () => []);
              brandGroups[vehicle.brand]![vehicle.model]!.add(vehicle);
              // Store brand logo URL (use first vehicle's brandLogoUrl for the brand)
              if (!brandLogoMap.containsKey(vehicle.brand) && vehicle.brandLogoUrl != null && vehicle.brandLogoUrl!.isNotEmpty) {
                brandLogoMap[vehicle.brand] = vehicle.brandLogoUrl;
              }
            }

            // Sort vehicles within each model by year (descending - newest first)
            for (final brand in brandGroups.keys) {
              for (final model in brandGroups[brand]!.keys) {
                brandGroups[brand]![model]!.sort((a, b) {
                  final aYear = a.endYear ?? a.year;
                  final bYear = b.endYear ?? b.year;
                  return bYear.compareTo(aYear);
                });
              }
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: brandGroups.length,
              itemBuilder: (context, index) {
                final brand = brandGroups.keys.elementAt(index);
                final models = brandGroups[brand]!;
                final brandLogoUrl = brandLogoMap[brand];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    leading: _BrandLogo(brand: brand, brandLogoUrl: brandLogoUrl),
                    title: Text(
                      brand,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('${models.length} model'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: models.length,
                          itemBuilder: (context, modelIndex) {
                            final modelName = models.keys.elementAt(modelIndex);
                            final modelVehicles = models[modelName]!;
                            // Get the latest year vehicle for the image
                            final latestVehicle = modelVehicles.first;
                            return _ModelCard(
                              modelName: modelName,
                              vehicle: latestVehicle,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => _VehicleYearsScreen(
                                    brand: brand,
                                    model: modelName,
                                    vehicles: modelVehicles,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.brand, this.brandLogoUrl});

  final String brand;
  final String? brandLogoUrl;

  @override
  Widget build(BuildContext context) {
    final logoUrl = brandLogoUrl;
    
    if (logoUrl == null || logoUrl.isEmpty) {
      // No logo available, show initial letter
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        radius: 20,
        child: Text(
          brand[0].toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }
    
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      radius: 20,
      child: ClipOval(
        child: Image.network(
          logoUrl,
          width: 40,
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              brand[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                brand[0].toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.modelName,
    required this.vehicle,
    required this.onTap,
  });

  final String modelName;
  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty
                    ? Image.network(
                        vehicle.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Icon(Icons.directions_car, size: 40, color: Colors.grey),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(Icons.directions_car, size: 40, color: Colors.grey),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      modelName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.yearLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleYearsScreen extends StatelessWidget {
  const _VehicleYearsScreen({
    required this.brand,
    required this.model,
    required this.vehicles,
  });

  final String brand;
  final String model;
  final List<Vehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$brand $model')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return _VehicleYearCard(
            vehicle: vehicle,
            brand: brand,
            model: model,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PartsListPage(
                  initialQuery: '$brand $model',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VehicleYearCard extends StatelessWidget {
  const _VehicleYearCard({
    required this.vehicle,
    required this.brand,
    required this.model,
    required this.onTap,
  });

  final Vehicle vehicle;
  final String brand;
  final String model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty
                    ? Image.network(
                        vehicle.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Icon(Icons.directions_car, size: 40, color: Colors.grey),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(Icons.directions_car, size: 40, color: Colors.grey),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vehicle.yearLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (vehicle.engine != null && vehicle.engine!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        vehicle.engine!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
