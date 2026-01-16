import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_store.dart';

class ConfirmEmailScreen extends StatefulWidget {
  const ConfirmEmailScreen({super.key, this.email, this.token});

  final String? email;
  final String? token;

  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends State<ConfirmEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.email ?? '';
    _tokenCtrl.text = widget.token ?? '';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('E-posta onay\u0131')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (auth.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(31),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(auth.error!, style: const TextStyle(color: Colors.redAccent)),
            ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'E-posta'),
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tokenCtrl,
                  decoration: const InputDecoration(labelText: 'Kod'),
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: auth.isBusy ? null : () => _confirm(),
                  child: auth.isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Onayla'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: auth.isBusy ? null : () => _resend(),
                  child: const Text('Onay e-postas\u0131n\u0131 tekrar g\u00F6nder'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthStore>();
    final result = await auth.confirmEmail(_emailCtrl.text.trim(), _tokenCtrl.text.trim());
    if (result == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    Navigator.of(context).pop();
  }

  Future<void> _resend() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    final auth = context.read<AuthStore>();
    final result = await auth.resendConfirm(_emailCtrl.text.trim());
    if (result == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }
}
