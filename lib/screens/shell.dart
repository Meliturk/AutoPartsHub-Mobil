import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/cart_store.dart';
import 'account_screen.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'parts_list_screen.dart';
import 'vehicles_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const PartsListScreen(),
      const VehiclesScreen(),
      const CartScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
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
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (value) => setState(() => _index = value),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFF6B35),
          unselectedItemColor: Colors.grey.shade400,
          items: [
            BottomNavigationBarItem(
              icon: Icon(_index == 0 ? Icons.home_rounded : Icons.home_outlined),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(_index == 1 ? Icons.search_rounded : Icons.search_outlined),
              label: 'Par\u00E7alar',
            ),
            BottomNavigationBarItem(
              icon: Icon(_index == 2 ? Icons.directions_car_rounded : Icons.directions_car_outlined),
              label: 'Ara\u00E7lar',
            ),
            BottomNavigationBarItem(
              icon: Consumer<CartStore>(
                builder: (context, cart, _) => _NavBadge(
                  count: cart.totalCount,
                  icon: _index == 3 ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
                ),
              ),
              label: 'Sepet',
            ),
            BottomNavigationBarItem(
              icon: Icon(_index == 4 ? Icons.person_rounded : Icons.person_outline),
              label: 'Hesap',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  const _NavBadge({required this.count, required this.icon});

  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
