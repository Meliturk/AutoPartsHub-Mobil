import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    required this.count,
    this.size = 14,
  });

  final double rating;
  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < fullStars ? Icons.star : Icons.star_border,
            size: size,
            color: const Color(0xFFF59E0B),
          ),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }
}
