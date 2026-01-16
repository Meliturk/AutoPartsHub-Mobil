import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_store.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'register_screen.dart';
import 'seller_apply_screen.dart';
import 'seller_dashboard_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static String _getRoleLabel(String role) {
    switch (role) {
      case 'User':
        return 'Kullan\u0131c\u0131';
      case 'Seller':
        return 'Sat\u0131c\u0131';
      case 'SellerPending':
        return 'Sat\u0131c\u0131 (Beklemede)';
      case 'Admin':
        return 'Y\u00F6netici';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AuthStore>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) {
            return _GuestView(
              onLogin: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              onRegister: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
            );
          }

          final session = auth.session!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Hesap',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0B1F3A),
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(session.email, style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Text('Rol: ${_getRoleLabel(session.role)}',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                  if (result == true) {
                    await context.read<AuthStore>().refresh();
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Profili D\u00FCzenle'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                ),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Sipari\u015Flerim'),
              ),
              if (session.role == 'Seller')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SellerDashboardScreen()),
                    ),
                    icon: const Icon(Icons.store),
                    label: const Text('Sat\u0131c\u0131 Paneli'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1F3A),
                    ),
                  ),
                ),
              if (session.role == 'User' || session.role == 'SellerPending')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SellerApplyScreen()),
                    ),
                    icon: const Icon(Icons.store),
                    label: const Text('Sat\u0131c\u0131 Ba\u015Fvurusu Yap'),
                  ),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: auth.logout,
                child: const Text('\u00C7\u0131k\u0131\u015F yap'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Sipari\u015Flerinizi y\u00F6netmek i\u00E7in giri\u015F yap\u0131n',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onLogin, child: const Text('Giri\u015F')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRegister, child: const Text('Hesap olu\u015Ftur')),
          ],
        ),
      ),
    );
  }
}
