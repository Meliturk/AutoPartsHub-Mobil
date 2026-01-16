import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/part.dart';
import '../services/parts_service.dart';
import '../services/seller_service.dart';
import '../state/auth_store.dart';
import '../widgets/empty_state.dart';
import '../widgets/part_card.dart';
import 'part_detail_screen.dart';
import 'seller_create_product_screen.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  late Future<List<PartListItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<PartListItem>> _load() {
    final auth = context.read<AuthStore>();
    if (auth.session == null) throw Exception('Not authenticated');
    return context.read<SellerService>().getMyParts(auth.session!.token);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    if (auth.session == null) {
      return const Scaffold(
        body: Center(child: Text('Giriş yapmanız gerekiyor')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünlerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SellerCreateProductScreen()),
              );
              if (result == true) {
                setState(() => _future = _load());
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<PartListItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return EmptyState(
                title: 'Hata',
                subtitle: 'Ürünler yüklenemedi',
                icon: Icons.error_outline,
                onRetry: () => setState(() => _future = _load()),
              );
            }

            final parts = snapshot.data!;
            if (parts.isEmpty) {
              return EmptyState(
                title: 'Henüz ürün yok',
                subtitle: 'İlk ürününüzü eklemek için + butonuna basın',
                icon: Icons.inventory_2,
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.55,
              ),
              itemCount: parts.length,
              itemBuilder: (context, index) {
                final part = parts[index];
                return GestureDetector(
                  onLongPress: () => _showProductMenu(context, part),
                  child: PartCard(
                    part: part,
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SellerCreateProductScreen(partId: part.id),
                        ),
                      );
                      if (result == true) {
                        setState(() => _future = _load());
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showProductMenu(BuildContext context, PartListItem part) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Ürünü Düzenle'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SellerCreateProductScreen(partId: part.id),
                  ),
                ).then((result) {
                  if (result == true) {
                    setState(() => _future = _load());
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Stok Güncelle'),
              onTap: () {
                Navigator.pop(context);
                _showUpdateStockDialog(context, part);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateStockDialog(BuildContext context, PartListItem part) async {
    final stockController = TextEditingController(text: part.stock.toString());
    final loadingNotifier = ValueNotifier<bool>(false);
    
    await showDialog(
      context: context,
      builder: (dialogContext) => ValueListenableBuilder<bool>(
        valueListenable: loadingNotifier,
        builder: (context, loading, _) => AlertDialog(
          title: const Text('Stok Güncelle'),
          content: TextField(
            controller: stockController,
            enabled: !loading,
            decoration: const InputDecoration(
              labelText: 'Stok Miktarı',
              hintText: 'Stok miktarını girin',
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final stockText = stockController.text.trim();
                      final newStock = int.tryParse(stockText);
                      if (newStock == null || newStock < 0) {
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('Geçerli bir stok miktarı girin')),
                          );
                        }
                        return;
                      }

                      loadingNotifier.value = true;
                      try {
                        final auth = context.read<AuthStore>();
                        if (auth.session == null) throw Exception('Not authenticated');

                        // Ürün bilgilerini yükle
                        final partsService = context.read<PartsService>();
                        final partDetail = await partsService.getPart(part.id);

                        // Stok hariç tüm bilgileri kullanarak updatePart çağır
                        final sellerService = context.read<SellerService>();
                        await sellerService.updatePart(
                          token: auth.session!.token,
                          partId: part.id,
                          name: partDetail.name,
                          brand: partDetail.brand,
                          category: partDetail.category,
                          price: partDetail.price,
                          stock: newStock,
                          description: partDetail.description,
                          vehicleIds: partDetail.vehicles.map((v) => v.id).toList(),
                          // Görselleri değiştirme
                        );

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Stok güncellendi')),
                            );
                            setState(() => _future = _load());
                          }
                        }
                      } catch (e) {
                        loadingNotifier.value = false;
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text('Hata: ${e.toString()}')),
                          );
                        }
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }
}
