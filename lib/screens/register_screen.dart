import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth.dart';
import '../state/auth_store.dart';
import 'confirm_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Kay\u0131t ol')),
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
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Ad soyad'),
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'E-posta'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: '\u015Eifre'),
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
                      : const Text('Hesap olu\u015Ftur'),
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
    final result = await auth.register(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );
    if (!mounted || result == null) return;
    await _showResult(result);
  }

  Future<void> _showResult(AuthActionResult result) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('E-postan\u0131 kontrol et'),
          content: Text(result.message),
          actions: [
            if (result.confirmToken != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ConfirmEmailScreen(
                        email: _emailCtrl.text.trim(),
                        token: result.confirmToken!,
                      ),
                    ),
                  );
                },
                child: const Text('\u015Eimdi onayla'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}
