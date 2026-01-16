import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/filters.dart';
import '../models/part.dart';
import '../services/parts_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/part_card.dart';
import 'part_detail_screen.dart';
import 'parts_list_screen.dart';
import 'vehicles_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final service = context.read<PartsService>();
    final filters = await service.getFilters();
    final parts = await service.getParts();
    return _HomeData(filters: filters, featured: parts.take(8).toList());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<_HomeData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const EmptyState(
              title: 'Veri yok',
              subtitle: 'Katalog y\u00FCklenemedi.',
              icon: Icons.cloud_off,
            );
          }

          final data = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HeroBanner(onSearch: _openSearch, onVehiclesTap: _openVehicles)),
              SliverToBoxAdapter(
                child: _CategoryStrip(
                  categories: data.filters.categories,
                  onTap: _openCategory,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\u00D6ne \u00E7\u0131kan par\u00E7alar',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1F36),
                              fontSize: 20,
                              letterSpacing: -0.5,
                            ),
                      ),
                      TextButton(
                        onPressed: () => _openCategory(null),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'T\u00FCm\u00FCn\u00FC g\u00F6r',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (data.featured.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    title: 'Hen\u00FCz par\u00E7a yok',
                    subtitle: 'Y\u00F6netim panelinden \u00FCr\u00FCn ekleyin.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.55,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final part = data.featured[index];
                        return PartCard(
                          part: part,
                          onTap: () => _openDetail(part),
                        );
                      },
                      childCount: data.featured.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openDetail(PartListItem part) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PartDetailScreen(partId: part.id)),
    );
  }

  void _openSearch(String query) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PartsListPage(initialQuery: query),
      ),
    );
  }

  void _openCategory(String? category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PartsListPage(initialCategory: category),
      ),
    );
  }

  void _openVehicles() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VehiclesScreen()),
    );
  }
}

class _HomeData {
  const _HomeData({required this.filters, required this.featured});

  final PartsFilterMeta filters;
  final List<PartListItem> featured;
}

class _HeroBanner extends StatefulWidget {
  const _HeroBanner({required this.onSearch, required this.onVehiclesTap});

  final void Function(String query) onSearch;
  final VoidCallback onVehiclesTap;

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1A1F36),
              Color(0xFF2D3748),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1F36).withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.build_circle_outlined,
                        color: Colors.white,
                        size: 28,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AutoParts Hub',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Arac\u0131n\u0131z i\u00E7in do\u011Fru par\u00E7ay\u0131 h\u0131zl\u0131ca bulun',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: widget.onSearch,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Par\u00E7a ad\u0131 veya marka ara...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
                  suffixIcon: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ),
                    onPressed: () => widget.onSearch(_controller.text.trim()),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: widget.onVehiclesTap,
              icon: const Icon(Icons.directions_car_rounded, size: 20),
              label: const Text(
                'Ara\u00E7lar\u0131 G\u00F6r\u00FCnt\u00FCle',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.categories, required this.onTap});

  final List<String> categories;
  final void Function(String? category) onTap;

  static IconData _getCategoryIcon(String category) {
    // Tüm kategoriler için tamir anahtarı ikonu kullan
    return Icons.build_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final chips = categories.take(10).toList();
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index >= chips.length) return const SizedBox.shrink();
          final label = chips[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(label),
              borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(label),
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: chips.length,
      ),
    );
  }
}
