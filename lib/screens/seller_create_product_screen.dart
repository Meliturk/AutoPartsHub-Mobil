import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/filters.dart';
import '../models/part.dart';
import '../models/vehicle.dart';
import '../services/parts_service.dart';
import '../services/seller_service.dart';
import '../state/auth_store.dart';

class SellerCreateProductScreen extends StatefulWidget {
  const SellerCreateProductScreen({super.key, this.partId});

  final int? partId;

  @override
  State<SellerCreateProductScreen> createState() => _SellerCreateProductScreenState();
}

class _SellerCreateProductScreenState extends State<SellerCreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  File? _image;
  List<File> _gallery = [];
  List<int> _selectedVehicleIds = [];
  PartsFilterMeta? _filters;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    if (widget.partId != null) {
      _loadPart();
    }
  }

  Future<void> _loadPart() async {
    try {
      final part = await context.read<PartsService>().getPart(widget.partId!);
      if (!mounted) return;
      
      setState(() {
        _nameCtrl.text = part.name;
        _brandCtrl.text = part.brand;
        _categoryCtrl.text = part.category;
        _priceCtrl.text = part.price.toString();
        _stockCtrl.text = part.stock.toString();
        _descriptionCtrl.text = part.description ?? '';
        _selectedVehicleIds = part.vehicles.map((v) => v.id).toList();
        // Not: Görseller yüklenemez (network image'lar), bu yüzden kullanıcı yeni görsel seçebilir
      });
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _categoryCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    try {
      final filters = await context.read<PartsService>().getFilters();
      setState(() => _filters = filters);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 85);
    if (image == null) return;
    setState(() => _image = File(image.path));
  }

  Future<void> _pickGallery() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;
    setState(() => _gallery = images.map((e) => File(e.path)).toList());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthStore>();
      if (auth.session == null) throw Exception('Not authenticated');

      final service = context.read<SellerService>();
      final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
      final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

      if (widget.partId != null) {
        await service.updatePart(
          token: auth.session!.token,
          partId: widget.partId!,
          name: _nameCtrl.text.trim(),
          brand: _brandCtrl.text.trim(),
          category: _categoryCtrl.text.trim(),
          price: price,
          stock: stock,
          description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
          vehicleIds: _selectedVehicleIds.isEmpty ? null : _selectedVehicleIds,
          image: _image,
          gallery: _gallery.isEmpty ? null : _gallery,
        );
      } else {
        await service.createPart(
          token: auth.session!.token,
          name: _nameCtrl.text.trim(),
          brand: _brandCtrl.text.trim(),
          category: _categoryCtrl.text.trim(),
          price: price,
          stock: stock,
          description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
          vehicleIds: _selectedVehicleIds.isEmpty ? null : _selectedVehicleIds,
          image: _image,
          gallery: _gallery.isEmpty ? null : _gallery,
        );
      }

      if (!mounted) return;
      // Filters'ı yeniden yükle ki yeni eklenen markalar görünsün
      await _loadFilters();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('ApiException(', '').replaceFirst(')', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partId != null ? 'Ürün Düzenle' : 'Yeni Ürün'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(31),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Ürün Adı *'),
                  validator: (v) => v?.isEmpty ?? true ? 'Zorunlu' : null,
                ),
                const SizedBox(height: 12),
                if (_filters != null)
                  Autocomplete<String>(
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return _filters!.partBrands;
                      }
                      return _filters!.partBrands
                          .where((brand) => brand
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()))
                          .toList();
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      textEditingController.text = _brandCtrl.text;
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        onChanged: (value) => _brandCtrl.text = value,
                        decoration: const InputDecoration(
                          labelText: 'Marka *',
                          hintText: 'Marka seçin veya yazın',
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Zorunlu' : null,
                        onFieldSubmitted: (value) => onFieldSubmitted(),
                      );
                    },
                    onSelected: (value) {
                      _brandCtrl.text = value;
                    },
                  )
                else
                  TextFormField(
                    controller: _brandCtrl,
                    decoration: const InputDecoration(labelText: 'Marka *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Zorunlu' : null,
                  ),
                const SizedBox(height: 12),
                if (_filters != null)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Kategori *'),
                    items: _filters!.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => _categoryCtrl.text = v ?? '',
                    validator: (v) => v == null || v.isEmpty ? 'Zorunlu' : null,
                  )
                else
                  TextFormField(
                    controller: _categoryCtrl,
                    decoration: const InputDecoration(labelText: 'Kategori *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Zorunlu' : null,
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(labelText: 'Fiyat (₺) *'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Zorunlu';
                    if (double.tryParse(v!) == null) return 'Geçersiz';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stockCtrl,
                  decoration: const InputDecoration(labelText: 'Stok *'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Zorunlu';
                    if (int.tryParse(v!) == null) return 'Geçersiz';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                Text(
                  'Ana Görsel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (_image != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _image = null),
                        ),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Görsel Seç'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Galeri Görselleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (_gallery.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _gallery.asMap().entries.map((entry) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(entry.value, width: 100, height: 100, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 20, color: Colors.white),
                              onPressed: () => setState(() => _gallery.removeAt(entry.key)),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Galeri Ekle'),
                  onPressed: _pickGallery,
                ),
                const SizedBox(height: 24),
                if (_filters != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Uyumlu Araçlar (Opsiyonel)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (_selectedVehicleIds.isNotEmpty)
                        Chip(
                          label: Text('${_selectedVehicleIds.length} seçili'),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.directions_car),
                    label: Text(_selectedVehicleIds.isEmpty
                        ? 'Araç Seç'
                        : '${_selectedVehicleIds.length} Araç Seçili'),
                    onPressed: () => _selectVehicles(context),
                  ),
                  if (_selectedVehicleIds.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedVehicleIds.map((id) {
                        final vehicle = _filters!.vehicles.firstWhere((v) => v.id == id);
                        return Chip(
                          label: Text('${vehicle.brand} ${vehicle.model} ${vehicle.yearLabel}'),
                          onDeleted: () {
                            setState(() => _selectedVehicleIds.remove(id));
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(widget.partId != null ? 'Güncelle' : 'Oluştur'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectVehicles(BuildContext context) async {
    if (_filters == null) return;

    final selected = await showDialog<List<int>>(
      context: context,
      builder: (context) => _VehicleSelectionDialog(
        vehicles: _filters!.vehicles,
        selectedIds: List.from(_selectedVehicleIds),
      ),
    );

    if (selected != null) {
      setState(() => _selectedVehicleIds = selected);
    }
  }
}

class _VehicleSelectionDialog extends StatefulWidget {
  const _VehicleSelectionDialog({
    required this.vehicles,
    required this.selectedIds,
  });

  final List<Vehicle> vehicles;
  final List<int> selectedIds;

  @override
  State<_VehicleSelectionDialog> createState() => _VehicleSelectionDialogState();
}

class _VehicleSelectionDialogState extends State<_VehicleSelectionDialog> {
  final _searchController = TextEditingController();
  late List<int> _selectedIds;
  List<Vehicle> _filteredVehicles = [];

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedIds);
    _filteredVehicles = widget.vehicles;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterVehicles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVehicles = widget.vehicles;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredVehicles = widget.vehicles
            .where((v) =>
                v.brand.toLowerCase().contains(lowerQuery) ||
                v.model.toLowerCase().contains(lowerQuery) ||
                v.yearLabel.contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group by brand and model
    final grouped = <String, List<Vehicle>>{};
    for (final vehicle in _filteredVehicles) {
      final key = '${vehicle.brand} ${vehicle.model}';
      grouped.putIfAbsent(key, () => []).add(vehicle);
    }

    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Araç Seç',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (_selectedIds.isNotEmpty)
                    Chip(
                      label: Text('${_selectedIds.length} seçili'),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Marka, model veya yıl ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterVehicles('');
                          },
                        )
                      : null,
                ),
                onChanged: _filterVehicles,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final key = grouped.keys.elementAt(index);
                  final vehicles = grouped[key]!;
                  // Sort vehicles by year
                  vehicles.sort((a, b) {
                    final aStart = a.startYear ?? a.year;
                    final bStart = b.startYear ?? b.year;
                    return aStart.compareTo(bStart);
                  });

                  // Group consecutive years
                  final yearGroups = <List<Vehicle>>[];
                  for (final vehicle in vehicles) {
                    if (yearGroups.isEmpty) {
                      yearGroups.add([vehicle]);
                    } else {
                      final lastGroup = yearGroups.last;
                      final lastVehicle = lastGroup.last;
                      final lastEnd = lastVehicle.endYear ?? lastVehicle.year;
                      final currentStart = vehicle.startYear ?? vehicle.year;
                      
                      if (currentStart <= lastEnd + 1) {
                        // Merge with previous group
                        lastGroup.add(vehicle);
                      } else {
                        yearGroups.add([vehicle]);
                      }
                    }
                  }

                  final allSelected = vehicles.every((v) => _selectedIds.contains(v.id));
                  final someSelected = vehicles.any((v) => _selectedIds.contains(v.id)) && !allSelected;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      leading: Checkbox(
                        value: allSelected ? true : (someSelected ? null : false),
                        tristate: true,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              for (final v in vehicles) {
                                if (!_selectedIds.contains(v.id)) {
                                  _selectedIds.add(v.id);
                                }
                              }
                            } else {
                              for (final v in vehicles) {
                                _selectedIds.remove(v.id);
                              }
                            }
                          });
                        },
                      ),
                      title: Text(
                        key,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        yearGroups.map((group) {
                          if (group.length == 1) {
                            return group.first.yearLabel;
                          }
                          final first = group.first.startYear ?? group.first.year;
                          final last = group.last.endYear ?? group.last.year;
                          return '$first-$last';
                        }).join(', '),
                      ),
                      children: yearGroups.map((group) {
                        final yearRange = group.length == 1
                            ? group.first.yearLabel
                            : '${group.first.startYear ?? group.first.year}-${group.last.endYear ?? group.last.year}';
                        
                        return CheckboxListTile(
                          title: Text(yearRange),
                          subtitle: group.first.engine != null ? Text(group.first.engine!) : null,
                          value: group.every((v) => _selectedIds.contains(v.id)),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                for (final v in group) {
                                  if (!_selectedIds.contains(v.id)) {
                                    _selectedIds.add(v.id);
                                  }
                                }
                              } else {
                                for (final v in group) {
                                  _selectedIds.remove(v.id);
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_selectedIds),
                      child: const Text('Seç'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
