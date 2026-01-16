import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../services/orders_service.dart';
import '../state/auth_store.dart';
import '../widgets/empty_state.dart';

final _priceFormat = NumberFormat.simpleCurrency(name: 'TRY', decimalDigits: 0);

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future<List<Order>>? _future;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthStore>().session;
    if (session != null) {
      _future = context.read<OrdersService>().getMyOrders(session.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthStore>().session;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sipari\u015Flerim')),
        body: const Center(child: Text('Giri\u015F gerekli.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sipari\u015Flerim')),
      body: FutureBuilder<List<Order>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const EmptyState(
              title: 'Sipari\u015F yok',
              subtitle: 'Sipari\u015Fler y\u00FCklenemedi.',
              icon: Icons.receipt_long,
            );
          }

          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const EmptyState(
              title: 'Sipari\u015F yok',
              subtitle: 'Sipari\u015F ge\u00E7mi\u015Finiz bo\u015F.',
              icon: Icons.receipt_long,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('#${order.id}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        _StatusChip(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(order.createdAt.toLocal()),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ...order.items.take(3).map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${item.partName} x${item.quantity}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                        ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _priceFormat.format(order.total),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF0B1F3A),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'Pending':
        color = Colors.orangeAccent;
        label = 'Beklemede';
        break;
      case 'Processing':
        color = Colors.blueAccent;
        label = '\u0130\u015Fleniyor';
        break;
      case 'Shipped':
        color = Colors.indigo;
        label = 'Kargoda';
        break;
      case 'Cancelled':
        color = Colors.redAccent;
        label = '\u0130ptal';
        break;
      case 'Completed':
        color = Colors.green;
        label = 'Tamamland\u0131';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
