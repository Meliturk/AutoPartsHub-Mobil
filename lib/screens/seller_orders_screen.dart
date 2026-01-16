import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/seller.dart';
import '../services/seller_service.dart';
import '../state/auth_store.dart';
import '../widgets/empty_state.dart';

final _currencyFormat = NumberFormat.simpleCurrency(name: 'TRY', decimalDigits: 0);
final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  late Future<List<SellerOrder>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SellerOrder>> _load() {
    final auth = context.read<AuthStore>();
    if (auth.session == null) throw Exception('Not authenticated');
    return context.read<SellerService>().getOrders(auth.session!.token);
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
      appBar: AppBar(title: const Text('Siparişlerim')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<SellerOrder>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return EmptyState(
                title: 'Hata',
                subtitle: 'Siparişler yüklenemedi',
                icon: Icons.error_outline,
                onRetry: () => setState(() => _future = _load()),
              );
            }

            final orders = snapshot.data!;
            final visibleOrders = orders
                .where((order) => order.status.toLowerCase() != 'completed')
                .toList();
            if (visibleOrders.isEmpty) {
              return const EmptyState(
                title: 'Henüz sipariş yok',
                subtitle: 'Siparişler burada görünecek',
                icon: Icons.shopping_bag,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visibleOrders.length,
              itemBuilder: (context, index) {
                final order = visibleOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(order.status).withAlpha(31),
                      child: Icon(Icons.shopping_bag, color: _getStatusColor(order.status)),
                    ),
                    title: Text(
                      order.customerName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${_dateFormat.format(order.createdAt)} • ${_currencyFormat.format(order.total)}',
                    ),
                    trailing: Chip(
                      label: Text(
                        _getStatusText(order.status),
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: _getStatusColor(order.status),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.partName} x ${item.quantity}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                        _currencyFormat.format(item.unitPrice * item.quantity),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Toplam:',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  _currencyFormat.format(order.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (order.status != 'Completed' && order.status != 'Cancelled')
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _updateStatus(order),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Durum Güncelle'),
                                ),
                              ),
                          ],
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Beklemede';
      case 'processing':
        return 'Hazırlanıyor';
      case 'shipped':
        return 'Kargoya Verildi';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return status;
    }
  }

  Future<void> _updateStatus(SellerOrder order) async {
    final status = await showDialog<String>(
      context: context,
      builder: (context) => _StatusDialog(currentStatus: order.status),
    );
    if (status == null) return;

    final auth = context.read<AuthStore>();
    if (auth.session == null) return;

    try {
      await context.read<SellerService>().updateOrderStatus(
            token: auth.session!.token,
            orderId: order.orderId,
            status: status,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Durum güncellendi')),
      );
      setState(() => _future = _load());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

class _StatusDialog extends StatefulWidget {
  const _StatusDialog({required this.currentStatus});

  final String currentStatus;

  @override
  State<_StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<_StatusDialog> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    final statuses = ['Pending', 'Processing', 'Shipped', 'Completed', 'Cancelled'];
    final statusTexts = {
      'Pending': 'Beklemede',
      'Processing': 'Hazırlanıyor',
      'Shipped': 'Kargoya Verildi',
      'Completed': 'Tamamlandı',
      'Cancelled': 'İptal Edildi',
    };

    return AlertDialog(
      title: const Text('Durum Seç'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: statuses.map((status) {
          return RadioListTile<String>(
            title: Text(statusTexts[status] ?? status),
            value: status,
            groupValue: _selectedStatus,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedStatus = value);
                Navigator.of(context).pop(value);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}




