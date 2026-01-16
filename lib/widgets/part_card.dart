import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/part.dart';
import '../state/cart_store.dart';
import 'rating_stars.dart';

final _priceFormat = NumberFormat.simpleCurrency(name: 'TRY', decimalDigits: 0);

class PartCard extends StatelessWidget {
  const PartCard({
    super.key,
    required this.part,
    this.onTap,
  });

  final PartListItem part;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = part.imageUrl;
    final stockColor = part.stock <= 0
        ? const Color(0xFFEF4444)
        : part.stock <= 3
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      SizedBox.expand(
                        child: imageUrl == null || imageUrl.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey.shade100,
                                      Colors.grey.shade50,
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                                ),
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey.shade100,
                                        Colors.grey.shade50,
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
                                  ),
                                ),
                              ),
                      ),
                      // Stock badge overlay
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: stockColor.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            part.stock <= 0 ? 'Stokta Yok' : 'Stok ${part.stock}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content Section
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        part.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.2,
                          color: const Color(0xFF1A1F36),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Brand & Category
                      Text(
                        '${part.brand} • ${part.category}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Rating
                      RatingStars(rating: part.rating, count: part.ratingCount),
                      const Spacer(flex: 1),
                      // Price & Add to Cart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              _priceFormat.format(part.price),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF1A1F36),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Add to Cart Button
                      GestureDetector(
                        onTap: () {},
                        child: SizedBox(
                          width: double.infinity,
                          height: 28,
                          child: ElevatedButton.icon(
                            onPressed: part.stock <= 0
                                ? null
                                : () {
                                    final cart = context.read<CartStore>();
                                    cart.addItem(
                                      CartItem(
                                        partId: part.id,
                                        name: part.name,
                                        brand: part.brand,
                                        price: part.price,
                                        quantity: 1,
                                        imageUrl: part.imageUrl,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text('Sepete eklendi'),
                                          ],
                                        ),
                                        backgroundColor: const Color(0xFF10B981),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        margin: const EdgeInsets.all(16),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.shopping_bag_outlined, size: 14),
                            label: const Text(
                              'Sepete Ekle',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 28),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
