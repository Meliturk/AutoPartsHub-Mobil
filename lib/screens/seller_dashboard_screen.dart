import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/seller.dart';
import '../services/seller_service.dart';
import '../state/auth_store.dart';
import '../widgets/empty_state.dart';
import 'seller_orders_screen.dart';
import 'seller_products_screen.dart';
import 'seller_questions_screen.dart';

final _currencyFormat = NumberFormat.simpleCurrency(name: 'TRY', decimalDigits: 0);

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  late Future<SellerDashboard> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<SellerDashboard> _load() {
    final auth = context.read<AuthStore>();
    if (auth.session == null) throw Exception('Not authenticated');
    return context.read<SellerService>().getDashboard(auth.session!.token);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    if (auth.session == null) {
      return const Scaffold(
        body: Center(child: Text('Giriş yapmanız gerekiyor')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Satıcı Paneli')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<SellerDashboard>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return EmptyState(
                title: 'Hata',
                subtitle: 'Dashboard yüklenemedi',
                icon: Icons.error_outline,
                onRetry: () => setState(() => _future = _load()),
              );
            }

            final dashboard = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatsCards(dashboard),
                const SizedBox(height: 24),
                _buildCharts(dashboard),
                const SizedBox(height: 24),
                _buildQuickActions(context, auth.session!.token),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsCards(SellerDashboard dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _StatCard('Günlük', _currencyFormat.format(dashboard.dayTotal), Icons.today, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard('Haftalık', _currencyFormat.format(dashboard.weekTotal), Icons.date_range, Colors.green)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard('Aylık', _currencyFormat.format(dashboard.monthTotal), Icons.calendar_month, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard('Ürünler', '${dashboard.partsCount}', Icons.inventory, Colors.purple)),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard('Toplam Sipariş', '${dashboard.ordersCount}', Icons.shopping_bag, Colors.red, fullWidth: true),
      ],
    );
  }

  Widget _buildCharts(SellerDashboard dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Satış Analizi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B1F36),
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '7 Günlük Satış',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Toplam sipariş: ${dashboard.ordersCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _DailySalesChart(chartPoints: dashboard.chartPoints),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ürün Bazlı Gelir (30 Gün)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                if (dashboard.productSales.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Henüz satış yok.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: (dashboard.productSales.length * 60.0) + 80,
                    child: _ProductRevenueChart(productSales: dashboard.productSales),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, String token) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Hızlı İşlemler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B1F3A),
              ),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          title: 'Ürünlerimi Yönet',
          subtitle: 'Ürün ekle, düzenle veya sil',
          icon: Icons.inventory_2,
          color: Colors.blue,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SellerProductsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          title: 'Gelen Sorular',
          subtitle: 'Müşteri sorularını yanıtla',
          icon: Icons.question_answer,
          color: Colors.orange,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SellerQuestionsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          title: 'Siparişlerim',
          subtitle: 'Siparişleri görüntüle ve yönet',
          icon: Icons.receipt_long,
          color: Colors.green,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SellerOrdersScreen()),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.icon, this.color, {this.fullWidth = false});

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0B1F3A),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(31),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _DailySalesChart extends StatelessWidget {
  const _DailySalesChart({required this.chartPoints});

  final List<SellerChartPoint> chartPoints;

  @override
  Widget build(BuildContext context) {
    if (chartPoints.isEmpty) {
      return Center(
        child: Text(
          'Veri yok',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      );
    }

    final maxValue = chartPoints.map((p) => p.total).reduce((a, b) => a > b ? a : b);
    final currencyFormat = NumberFormat.simpleCurrency(name: 'TRY', decimalDigits: 0);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    currencyFormat.format(value),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartPoints.length) {
                  return Text(
                    chartPoints[index].label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minY: 0,
        maxY: maxValue > 0 ? maxValue * 1.2 : 100,
        lineBarsData: [
          LineChartBarData(
            spots: chartPoints.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.total);
            }).toList(),
            isCurved: true,
            color: const Color(0xFFFF6B35),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFFF6B35).withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRevenueChart extends StatelessWidget {
  const _ProductRevenueChart({required this.productSales});

  final List<SellerProductSales> productSales;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(name: 'TRY', decimalDigits: 0);
    final maxValue = productSales.map((p) => p.total).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue > 0 ? maxValue * 1.2 : 100,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.grey.shade800,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final sales = productSales[groupIndex];
              return BarTooltipItem(
                '${currencyFormat.format(rod.toY)}\n${sales.quantity} adet',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < productSales.length) {
                  final name = productSales[index].name;
                  // İsimleri kısalt (mobil için)
                  final shortName = name.length > 18 ? '${name.substring(0, 18)}...' : name;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      shortName,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 70,
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: productSales.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.total,
                color: const Color(0xFF228BE6),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
