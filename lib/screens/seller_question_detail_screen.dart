import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/seller.dart';
import '../services/seller_service.dart';
import '../state/auth_store.dart';

final _detailDateFormat = DateFormat('dd.MM.yyyy HH:mm');

class SellerQuestionDetailScreen extends StatefulWidget {
  const SellerQuestionDetailScreen({super.key, required this.question});

  final SellerQuestion question;

  @override
  State<SellerQuestionDetailScreen> createState() => _SellerQuestionDetailScreenState();
}

class _SellerQuestionDetailScreenState extends State<SellerQuestionDetailScreen> {
  late final TextEditingController _answerCtrl;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _answerCtrl = TextEditingController(text: widget.question.answer ?? '');
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final hasAnswer = question.answer != null && question.answer!.trim().isNotEmpty;
    final title = hasAnswer ? 'Soru Detay\u0131' : 'Soru Yan\u0131tla';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProductInfoCard(question: question),
          const SizedBox(height: 16),
          _QuestionInfoCard(question: question),
          const SizedBox(height: 16),
          if (hasAnswer) _AnswerInfoCard(answer: question.answer!)
          else _AnswerForm(
            controller: _answerCtrl,
            submitting: _submitting,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final text = _answerCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('L\u00FCtfen yan\u0131t yaz\u0131n.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final auth = context.read<AuthStore>();
      if (auth.session == null) throw Exception('Not authenticated');

      await context.read<SellerService>().answerQuestion(
            token: auth.session!.token,
            questionId: widget.question.id,
            answer: text,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yan\u0131t g\u00F6nderildi.')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({required this.question});

  final SellerQuestion question;

  @override
  Widget build(BuildContext context) {
    final name = question.partName.isNotEmpty
        ? question.partName
        : '\u00DCr\u00FCn';
    final idLabel = question.partId > 0 ? '#${question.partId}' : null;
    final imageUrl = question.imageUrl;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              height: 72,
              color: const Color(0xFFF1F4FA),
              child: imageUrl == null || imageUrl.isEmpty
                  ? const Icon(Icons.image, color: Colors.grey)
                  : Image.network(
                      imageUrl,
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
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (idLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    idLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionInfoCard extends StatelessWidget {
  const _QuestionInfoCard({required this.question});

  final SellerQuestion question;

  @override
  Widget build(BuildContext context) {
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
            'Soru',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(question.question),
          const SizedBox(height: 12),
          Text(
            '${question.userName ?? 'Kullan\u0131c\u0131'} \u00B7 ${_detailDateFormat.format(question.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}

class _AnswerInfoCard extends StatelessWidget {
  const _AnswerInfoCard({required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
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
            'Yan\u0131t',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(answer),
        ],
      ),
    );
  }
}

class _AnswerForm extends StatelessWidget {
  const _AnswerForm({
    required this.controller,
    required this.submitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
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
            'Yan\u0131t\u0131n\u0131z',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Yan\u0131t\u0131n\u0131z\u0131 yaz\u0131n',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submitting ? null : onSubmit,
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('G\u00F6nder'),
            ),
          ),
        ],
      ),
    );
  }
}
