import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_store.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.email, this.token});

  final String? email;
  final String? token;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

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
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('\u015Eifre s\u0131f\u0131rla')),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Yeni \u015Fifre'),
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: auth.isBusy ? null : () => _submit(),
                  child: auth.isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('S\u0131f\u0131rla'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthStore>();
    final result = await auth.resetPassword(
      email: _emailCtrl.text.trim(),
      token: _tokenCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );
    if (result == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    Navigator.of(context).pop();
  }
}
