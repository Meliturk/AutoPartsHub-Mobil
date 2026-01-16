import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/filters.dart';
import '../models/part.dart';
import '../services/parts_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/part_card.dart';
import 'part_detail_screen.dart';
import 'vehicles_screen.dart';

class PartsListScreen extends StatelessWidget {
  const PartsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PartsListView();
  }
}

class PartsListPage extends StatelessWidget {
  const PartsListPage({super.key, this.initialQuery, this.initialCategory});

  final String? initialQuery;
  final String? initialCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Par\u00E7alar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car),
            tooltip: 'Araçlar',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VehiclesScreen()),
            ),
          ),
        ],
      ),
      body: PartsListView(
        initialQuery: initialQuery,
        initialCategory: initialCategory,
        showHeader: false,
      ),
    );
  }
}

class PartsListView extends StatefulWidget {
  const PartsListView({
    super.key,
    this.initialQuery,
    this.initialCategory,
    this.showHeader = true,
  });

  final String? initialQuery;
  final String? initialCategory;
  final bool showHeader;

  @override
  State<PartsListView> createState() => _PartsListViewState();
}

class _PartsListViewState extends State<PartsListView> {
  final _searchController = TextEditingController();
  PartsFilterMeta? _filters;
  List<PartListItem> _parts = [];
  String? _error;
  bool _loading = true;

  String? _category;
  String? _partBrand;
  String? _brand;
  String? _model;
  int? _year;
  double? _minPrice;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _category = widget.initialCategory;
    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = context.read<PartsService>();
      final filters = await service.getFilters();
      final parts = await service.getParts(
        query: _searchController.text.trim(),
        category: _category,
        partBrand: _partBrand,
        brand: _brand,
        model: _model,
        year: _year,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
      setState(() {
        _filters = filters;
        _parts = parts;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadAll,
        child: CustomScrollView(
          slivers: [
            if (widget.showHeader)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text(
                    'Par\u00E7a katalo\u011Fu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1F36),
                          fontSize: 24,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),
              ),
            SliverToBoxAdapter(child: _buildSearchBar(context)),
            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(
                child: EmptyState(
                  title: 'Y\u00FCkleme ba\u015Far\u0131s\u0131z',
                  subtitle: _error!,
                  icon: Icons.cloud_off,
                ),
              )
            else if (_parts.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  title: 'Sonu\u00E7 bulunamad\u0131',
                  subtitle: 'Filtreleri veya aramay\u0131 de\u011Fi\u015Ftirin.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.55,
                    ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final part = _parts[index];
                      return PartCard(
                        part: part,
                        onTap: () => _openDetail(part),
                      );
                    },
                    childCount: _parts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _loadAll(),
              decoration: InputDecoration(
                hintText: 'Par\u00E7a ara...',
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _filters == null ? null : () => _openFilters(context),
              icon: const Icon(Icons.tune_rounded, color: Colors.white),
              tooltip: 'Filtreler',
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(PartListItem part) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PartDetailScreen(partId: part.id)),
    );
  }

  Future<void> _openFilters(BuildContext context) async {
    final meta = _filters;
    if (meta == null) return;

    String? category = _category;
    String? partBrand = _partBrand;
    String? brand = _brand;
    String? model = _model;
    int? year = _year;
    final minCtrl = TextEditingController(text: _minPrice?.toStringAsFixed(0) ?? '');
    final maxCtrl = TextEditingController(text: _maxPrice?.toStringAsFixed(0) ?? '');

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final brands = _uniqueBrands(meta);
            final models = _uniqueModels(meta, brand);
            final years = _uniqueYears(meta, brand, model);
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Filtreler',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Kategori',
                    value: category,
                    options: meta.categories,
                    onChanged: (value) => setSheetState(() => category = value),
                  ),
                  _DropdownField(
                    label: 'Par\u00E7a markas\u0131',
                    value: partBrand,
                    options: meta.partBrands,
                    onChanged: (value) => setSheetState(() => partBrand = value),
                  ),
                  _DropdownField(
                    label: 'Ara\u00E7 markas\u0131',
                    value: brand,
                    options: brands,
                    onChanged: (value) {
                      setSheetState(() {
                        brand = value;
                        model = null;
                        year = null;
                      });
                    },
                  ),
                  _DropdownField(
                    label: 'Model',
                    value: model,
                    options: models,
                    onChanged: (value) {
                      setSheetState(() {
                        model = value;
                        year = null;
                      });
                    },
                  ),
                  _DropdownField(
                    label: 'Y\u0131l',
                    value: year?.toString(),
                    options: years.map((e) => e.toString()).toList(),
                    onChanged: (value) => setSheetState(() => year = int.tryParse(value ?? '')),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'En d\u00FC\u015F\u00FCk fiyat'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'En y\u00FCksek fiyat'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Vazge\u00E7'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Uygula'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (applied == true) {
      setState(() {
        _category = category;
        _partBrand = partBrand;
        _brand = brand;
        _model = model;
        _year = year;
        _minPrice = double.tryParse(minCtrl.text.trim());
        _maxPrice = double.tryParse(maxCtrl.text.trim());
      });
      await _loadAll();
    }
  }

  List<String> _uniqueBrands(PartsFilterMeta meta) {
    final set = meta.vehicles.map((e) => e.brand).where((e) => e.isNotEmpty).toSet();
    final list = set.toList();
    list.sort();
    return list;
  }

  List<String> _uniqueModels(PartsFilterMeta meta, String? brand) {
    final list = meta.vehicles
        .where((v) => brand == null || v.brand == brand)
        .map((e) => e.model)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  List<int> _uniqueYears(PartsFilterMeta meta, String? brand, String? model) {
    final set = <int>{};
    for (final v in meta.vehicles) {
      if (brand != null && v.brand != brand) continue;
      if (model != null && v.model != model) continue;
      final start = v.startYear ?? v.year;
      final end = v.endYear ?? v.year;
      for (var y = start; y <= end; y++) {
        set.add(y);
      }
    }
    final list = set.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String?>(
        key: ValueKey('$label-${value ?? "any"}'),
        initialValue: value != null && value!.isEmpty ? null : value,
        items: [
          const DropdownMenuItem(value: null, child: Text('T\u00FCm\u00FC')),
          ...options.map((option) => DropdownMenuItem(value: option, child: Text(option))),
        ],
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
