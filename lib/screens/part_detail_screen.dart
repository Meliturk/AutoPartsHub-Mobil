import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/part.dart';
import '../services/api_client.dart';
import '../services/parts_service.dart';
import '../state/auth_store.dart';
import '../state/cart_store.dart';
import '../widgets/empty_state.dart';
import '../widgets/rating_stars.dart';
import 'login_screen.dart';

final _priceFormat = NumberFormat.simpleCurrency(name: 'TRY', decimalDigits: 0);

class PartDetailScreen extends StatefulWidget {
  const PartDetailScreen({super.key, required this.partId});

  final int partId;

  @override
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  late Future<PartDetail> _future;
  final _pageController = PageController();
  int _pageIndex = 0;

  Future<PartDetail> _loadPart() {
    return context.read<PartsService>().getPart(widget.partId);
  }

  @override
  void initState() {
    super.initState();
    _future = _loadPart();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _refreshPart() {
    setState(() => _future = _loadPart());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Par\u00E7a detay\u0131')),
      body: FutureBuilder<PartDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const EmptyState(
              title: 'Veri yok',
              subtitle: 'Par\u00E7a detay\u0131 y\u00FCklenemedi.',
            );
          }
          final part = snapshot.data!;
          final isLoggedIn = auth.session != null;
          final gallery = [
            if (part.imageUrl != null && part.imageUrl!.isNotEmpty) part.imageUrl!,
            ...part.images.map((e) => e.url),
          ];

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildGallery(gallery),
                    const SizedBox(height: 16),
                    Text(
                      part.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${part.brand} - ${part.category}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    RatingStars(rating: part.rating, count: part.ratingCount, size: 16),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _priceFormat.format(part.price),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF0B1F3A),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        _StockBadge(stock: part.stock),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (part.vehicles.isNotEmpty) ...[
                      Text(
                        'Uyumlu ara\u00E7lar',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: part.vehicles
                            .map((v) => Chip(label: Text('${v.brand} ${v.model} ${v.yearLabel}')))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (part.description != null && part.description!.isNotEmpty) ...[
                      Text(
                        'A\u00E7\u0131klama',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        part.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (part.questions.isNotEmpty) ...[
                      _buildQuestions(part),
                      const SizedBox(height: 16),
                    ],
                    if (part.reviews.isNotEmpty) ...[
                      _buildReviews(part),
                      const SizedBox(height: 16),
                    ],
                    _buildFeedbackActions(part, isLoggedIn),
                    const SizedBox(height: 80), // Bottom bar için boşluk
                  ],
                ),
              ),
              _buildBottomBar(part),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGallery(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 240,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) => setState(() => _pageIndex = index),
              itemBuilder: (context, index) {
                final url = images[index];
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF1F4FA),
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _pageIndex ? const Color(0xFFFF7A00) : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestions(PartDetail part) {
    if (part.questions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sorular',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...part.questions.take(3).map(
              (q) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.userName ?? 'Kullan\u0131c\u0131',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(q.question),
                    if (q.answer != null && q.answer!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Yan\u0131t: ${q.answer}', style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildReviews(PartDetail part) {
    if (part.reviews.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'De\u011Ferlendirmeler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...part.reviews.take(3).map(
              (r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.userName ?? 'Kullan\u0131c\u0131',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    RatingStars(rating: r.rating.toDouble(), count: 0, size: 14),
                    if (r.comment != null && r.comment!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(r.comment!),
                    ],
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildFeedbackActions(PartDetail part, bool isLoggedIn) {
    final auth = context.watch<AuthStore>();
    final session = auth.session;
    final isSeller = session?.role == 'Seller';
    final canReview = isLoggedIn && !isSeller;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soru ve de\u011Ferlendirmeler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            !isLoggedIn
                ? 'Soru sormak veya de\u011Ferlendirme yapmak i\u00E7in giri\u015F yap.'
                : isSeller
                    ? 'Satıcılar değerlendirme yapamaz, ancak soru sorabilirsiniz.'
                    : 'Deneyimini payla\u015F veya sat\u0131c\u0131ya soru sor.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleQuestion(part),
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Sor'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canReview ? () => _handleReview(part) : null,
                  icon: const Icon(Icons.star_border),
                  label: const Text('De\u011Ferlendir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuestion(PartDetail part) async {
    final session = context.read<AuthStore>().session;
    if (session == null) {
      await _showLoginPrompt();
      return;
    }
    final question = await _showQuestionDialog();
    if (!mounted) return;
    if (question == null) return;

    try {
      final service = context.read<PartsService>();
      await service.askQuestion(part.id, question, token: session.token);
      if (!mounted) return;
      _showSnack('Soru g\u00F6nderildi.');
      _refreshPart();
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    }
  }

  Future<void> _handleReview(PartDetail part) async {
    final session = context.read<AuthStore>().session;
    if (session == null) {
      await _showLoginPrompt();
      return;
    }
    final review = await _showReviewDialog();
    if (!mounted) return;
    if (review == null) return;

    try {
      final service = context.read<PartsService>();
      await service.addReview(
            part.id,
            rating: review.rating,
            comment: review.comment,
            token: session.token,
          );
      if (!mounted) return;
      _showSnack('De\u011Ferlendirmeniz g\u00F6nderildi.');
      _refreshPart();
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
    }
  }

  Future<void> _showLoginPrompt() async {
    final shouldLogin = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Giri\u015F gerekli'),
          content: const Text('Devam etmek i\u00E7in giri\u015F yap\u0131n.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazge\u00E7'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Giri\u015F'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldLogin != true) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<String?> _showQuestionDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _QuestionDialog(),
    );
    if (result == null || result.trim().isEmpty) return null;
    return result.trim();
  }

  Future<_ReviewInput?> _showReviewDialog() async {
    return showDialog<_ReviewInput>(
      context: context,
      builder: (context) => const _ReviewDialog(),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : null,
      ),
    );
  }

  Widget _buildBottomBar(PartDetail part) {
    final canAddToCart = part.stock > 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _priceFormat.format(part.price),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF1A1F36),
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          letterSpacing: -0.5,
                        ),
                  ),
                  if (!canAddToCart)
                    Text(
                      'Stokta yok',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: canAddToCart ? () => _addToCart(part) : null,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Sepete ekle'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(PartDetail part) {
    context.read<CartStore>().addItem(
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
      const SnackBar(content: Text('Sepete eklendi')),
    );
  }
}

class _ReviewInput {
  const _ReviewInput(this.rating, this.comment);

  final int rating;
  final String? comment;
}

class _QuestionDialog extends StatefulWidget {
  const _QuestionDialog();

  @override
  State<_QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<_QuestionDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Soru sor'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'Sorunuzu yaz\u0131n'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazge\u00E7'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('G\u00F6nder'),
        ),
      ],
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog();

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _commentCtrl = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('De\u011Ferlendirme yap'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            key: ValueKey(_rating),
            initialValue: _rating,
            decoration: const InputDecoration(labelText: 'Puan'),
            items: List.generate(
              5,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text('${index + 1} y\u0131ld\u0131z'),
              ),
            ),
            onChanged: (value) => setState(() => _rating = value ?? 5),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Yorum (iste\u011Fe ba\u011Fl\u0131)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazge\u00E7'),
        ),
        TextButton(
          onPressed: () {
            final comment = _commentCtrl.text.trim();
            Navigator.of(context).pop(
              _ReviewInput(_rating, comment.isEmpty ? null : comment),
            );
          },
          child: const Text('G\u00F6nder'),
        ),
      ],
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final color = stock <= 0
        ? Colors.redAccent
        : stock <= 3
            ? Colors.orangeAccent
            : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        stock <= 0 ? 'T\u00FCkendi' : stock <= 3 ? 'Az kald\u0131' : 'Stokta',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
