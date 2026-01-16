import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/seller.dart';
import '../services/seller_service.dart';
import '../state/auth_store.dart';
import '../widgets/empty_state.dart';
import 'seller_question_detail_screen.dart';

final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

class SellerQuestionsScreen extends StatefulWidget {
  const SellerQuestionsScreen({super.key, this.showAnswered = false});

  final bool showAnswered;

  @override
  State<SellerQuestionsScreen> createState() => _SellerQuestionsScreenState();
}

class _SellerQuestionsScreenState extends State<SellerQuestionsScreen> {
  late Future<List<SellerQuestion>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SellerQuestion>> _load() {
    final auth = context.read<AuthStore>();
    if (auth.session == null) throw Exception('Not authenticated');
    return context.read<SellerService>().getQuestions(auth.session!.token);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    if (auth.session == null) {
      return const Scaffold(
        body: Center(child: Text('Giri\u015F yapman\u0131z gerekiyor')),
      );
    }

    final title = widget.showAnswered ? 'Yan\u0131tlanan Sorular' : 'Gelen Sorular';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: widget.showAnswered
            ? null
            : [
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SellerQuestionsScreen(showAnswered: true),
                    ),
                  ),
                  child: const Text('Yan\u0131tlananlar'),
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<List<SellerQuestion>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return EmptyState(
                title: 'Hata',
                subtitle: 'Sorular y\u00FCklenemedi',
                icon: Icons.error_outline,
                onRetry: () => setState(() => _future = _load()),
              );
            }

            final questions = snapshot.data!;
            final pending = questions
                .where((q) => q.answer == null || q.answer!.trim().isEmpty)
                .toList();
            final answered = questions
                .where((q) => q.answer != null && q.answer!.trim().isNotEmpty)
                .toList();
            final visibleQuestions = widget.showAnswered ? answered : pending;

            if (visibleQuestions.isEmpty) {
              return EmptyState(
                title: widget.showAnswered
                    ? 'Hen\u00FCz yan\u0131tlanan soru yok'
                    : 'Hen\u00FCz cevap bekleyen soru yok',
                subtitle: widget.showAnswered
                    ? 'Yan\u0131tlanan sorular burada g\u00F6r\u00FCnecek'
                    : 'M\u00FC\u015Fteri sorular\u0131 burada g\u00F6r\u00FCnecek',
                icon: Icons.question_answer,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visibleQuestions.length,
              itemBuilder: (context, index) {
                final question = visibleQuestions[index];
                final hasAnswer = question.answer != null && question.answer!.trim().isNotEmpty;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: _ProductThumb(imageUrl: question.imageUrl),
                    title: Text(
                      question.partName.isNotEmpty ? question.partName : '\u00DCr\u00FCn',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.question,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${question.userName ?? 'Kullan\u0131c\u0131'} \u00B7 ${_dateFormat.format(question.createdAt)}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    trailing: hasAnswer
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : IconButton(
                            icon: const Icon(Icons.reply),
                            onPressed: () => _openDetail(question),
                          ),
                    onTap: () => _openDetail(question),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openDetail(SellerQuestion question) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SellerQuestionDetailScreen(question: question),
      ),
    );
    if (result == true && mounted) {
      setState(() => _future = _load());
    }
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 56,
        height: 56,
        color: const Color(0xFFF1F4FA),
        child: url == null || url.isEmpty
            ? const Icon(Icons.image, color: Colors.grey)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
              ),
      ),
    );
  }
}
