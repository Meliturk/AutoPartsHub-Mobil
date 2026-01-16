import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/auth_store.dart';
import '../state/cart_store.dart';
import '../widgets/empty_state.dart';
import 'checkout_screen.dart';

final _priceFormat = NumberFormat.simpleCurrency(name: 'TRY', decimalDigits: 0);

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<CartStore, AuthStore>(
        builder: (context, cart, auth, _) {
          final session = auth.session;
          final canCheckout = session != null && session.role != 'Seller';
          if (cart.items.isEmpty) {
            return const EmptyState(
              title: 'Sepet bo\u015F',
              subtitle: '\u00D6deme i\u00E7in par\u00E7a ekleyin.',
              icon: Icons.shopping_bag_outlined,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Sepet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B1F3A),
                    ),
              ),
              const SizedBox(height: 12),
              ...cart.items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: item.imageUrl == null || item.imageUrl!.isEmpty
                            ? const Icon(Icons.image, color: Colors.grey)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(item.brand,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey.shade600)),
                            const SizedBox(height: 6),
                            Text(
                              _priceFormat.format(item.price),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: const Color(0xFF0B1F3A),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => cart.removeItem(item.partId),
                            icon: const Icon(Icons.delete_outline),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => cart.updateQuantity(item.partId, item.quantity - 1),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                onPressed: () => cart.updateQuantity(item.partId, item.quantity + 1),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Toplam',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _priceFormat.format(cart.totalPrice),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF0B1F3A),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: canCheckout
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                        );
                      }
                    : null,
                child: Text(canCheckout
                    ? '\u00D6deme'
                    : session == null
                        ? 'Giriş yapın'
                        : 'Satıcılar sipariş veremez'),
              ),
            ],
          );
        },
      ),
    );
  }
}
