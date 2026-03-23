import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';
import '../widgets/responsive_scaffold.dart';
import 'invoices_screen.dart';
import 'products_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  DashboardSummary? _summary;
  MonthlyChartData? _chartData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _dashboardService.getSummary(),
        _dashboardService.getMonthlyChart(),
      ]);
      setState(() {
        _summary = results[0] as DashboardSummary;
        _chartData = results[1] as MonthlyChartData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ResponsiveScaffold(
      currentRoute: 'dashboard',
      title: 'Ana Ekran',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: colorScheme.error, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadData, child: Text('Tekrar Dene')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Alert Banners ───
                        if (_summary!.overdueInvoices.isNotEmpty)
                          _buildOverdueAlertBanner(theme),
                        if (_summary!.stockAlerts.isNotEmpty)
                          _buildStockAlertBanner(theme),

                        // ─── Quick Stats ───
                        _buildQuickStats(colorScheme, theme),
                        const SizedBox(height: 16),

                        // ─── Charts Row ───
                        Text('Aylık Gelir & Gider',
                            style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        _buildChartCard(colorScheme),
                        const SizedBox(height: 16),

                        // ─── Pie Chart ───
                        if (_summary!.monthlyIncome > 0 || _summary!.monthlyExpense > 0) ...[
                          Text('Bu Ay Dağılım',
                              style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          _buildPieChart(colorScheme),
                          const SizedBox(height: 16),
                        ],

                        // ─── Overdue Invoices ───
                        if (_summary!.overdueInvoices.isNotEmpty) ...[
                          Text('Vadesi Geçen Faturalar',
                              style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          _buildOverdueInvoicesList(theme),
                          const SizedBox(height: 16),
                        ],

                        // ─── Stock Alerts ───
                        if (_summary!.stockAlerts.isNotEmpty) ...[
                          Text('Düşük Stok Uyarıları',
                              style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          _buildStockAlertsList(theme),
                          const SizedBox(height: 16),
                        ],

                        // ─── Recent Invoices ───
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Son Faturalar',
                                style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                            TextButton(
                              onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const InvoicesScreen())),
                              child: Text('Tümünü Gör', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        _buildRecentInvoices(theme),
                        const SizedBox(height: 16),

                        // ─── Upcoming Transactions ───
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Yaklaşan İşlemler',
                                style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                            TextButton(
                              onPressed: () {},
                              child: Text('Tümünü Gör', style: TextStyle(fontSize: 12)),
                            )
                          ],
                        ),
                        _buildUpcomingTransactions(theme),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ═══════════════════════════════════════════════
  // ALERT BANNERS
  // ═══════════════════════════════════════════════
  Widget _buildOverdueAlertBanner(ThemeData theme) {
    final count = _summary!.overdueInvoices.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count faturanın vadesi geçmiş!',
              style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const InvoicesScreen())),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: Size.zero,
            ),
            child: Text('Görüntüle', style: TextStyle(fontSize: 12, color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildStockAlertBanner(ThemeData theme) {
    final count = _summary!.stockAlerts.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count üründe stok düşük!',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProductsScreen())),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: Size.zero,
            ),
            child: Text('Görüntüle', style: TextStyle(fontSize: 12, color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // QUICK STATS
  // ═══════════════════════════════════════════════
  Widget _buildQuickStats(ColorScheme colorScheme, ThemeData theme) {
    final summary = _summary!;
    final incomeText = _formatCurrency(summary.monthlyIncome);
    final expenseText = _formatCurrency(summary.monthlyExpense);

    return Row(
      children: [
        Expanded(child: _buildStatCard('Gelir', '₺$incomeText', colorScheme.secondary, Icons.arrow_upward)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Gider', '₺$expenseText', colorScheme.error, Icons.arrow_downward)),
        const SizedBox(width: 8),
        Expanded(child: _buildClickablePendingCard(summary, theme)),
      ],
    );
  }

  Widget _buildClickablePendingCard(DashboardSummary summary, ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoicesScreen())),
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: const Color(0xFFF59E0B).withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bekleyen', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Icon(Icons.pending, color: const Color(0xFFF59E0B), size: 16),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('${summary.pendingInvoiceCount}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                  const SizedBox(width: 4),
                  Text('Fatura', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toStringAsFixed(0);
  }

  Widget _buildStatCard(String title, String amount, Color color, IconData icon) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Icon(icon, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 4),
            Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // LINE CHART
  // ═══════════════════════════════════════════════
  Widget _buildChartCard(ColorScheme colorScheme) {
    final chart = _chartData!;
    final incomeSpots = chart.incomeData.asMap().entries.map(
      (e) => FlSpot(e.key.toDouble() + 1, e.value.amount)).toList();
    final expenseSpots = chart.expenseData.asMap().entries.map(
      (e) => FlSpot(e.key.toDouble() + 1, e.value.amount)).toList();

    final maxY = [...chart.incomeData.map((e) => e.amount), ...chart.expenseData.map((e) => e.amount)]
        .fold(0.0, (a, b) => a > b ? a : b);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, top: 12.0, bottom: 4.0, left: 8.0),
        child: SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 18,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt() - 1;
                      final style = const TextStyle(color: Colors.grey, fontSize: 9);
                      if (idx >= 0 && idx < chart.incomeData.length) {
                        return SideTitleWidget(meta: meta, space: 4,
                          child: Text(chart.incomeData[idx].monthName, style: style));
                      }
                      return SideTitleWidget(meta: meta, space: 4, child: Text(''));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 1, maxX: chart.incomeData.length.toDouble(),
              minY: 0, maxY: maxY > 0 ? maxY * 1.2 : 40000,
              lineBarsData: [
                LineChartBarData(
                  spots: incomeSpots, isCurved: true, color: colorScheme.secondary,
                  barWidth: 1.5, isStrokeCapRound: true, dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: colorScheme.secondary.withOpacity(0.08)),
                ),
                LineChartBarData(
                  spots: expenseSpots, isCurved: true, color: colorScheme.error,
                  barWidth: 1.5, isStrokeCapRound: true, dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: colorScheme.error.withOpacity(0.08)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // PIE CHART (Donut)
  // ═══════════════════════════════════════════════
  Widget _buildPieChart(ColorScheme colorScheme) {
    final income = _summary!.monthlyIncome;
    final expense = _summary!.monthlyExpense;
    final total = income + expense;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 28,
                  sections: [
                    PieChartSectionData(
                      value: income,
                      color: colorScheme.secondary,
                      radius: 18,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: expense,
                      color: colorScheme.error,
                      radius: 18,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendRow(colorScheme.secondary, 'Gelir',
                      '₺${_formatCurrency(income)}',
                      total > 0 ? '${(income / total * 100).toStringAsFixed(0)}%' : '0%'),
                  const SizedBox(height: 10),
                  _buildLegendRow(colorScheme.error, 'Gider',
                      '₺${_formatCurrency(expense)}',
                      total > 0 ? '${(expense / total * 100).toStringAsFixed(0)}%' : '0%'),
                  const SizedBox(height: 10),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Net', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('₺${_formatCurrency(income - expense)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13,
                              color: income >= expense ? colorScheme.secondary : colorScheme.error)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, String value, String percent) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        Text(percent, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  // OVERDUE INVOICES LIST
  // ═══════════════════════════════════════════════
  Widget _buildOverdueInvoicesList(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.red.withOpacity(0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _summary!.overdueInvoices.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor),
        itemBuilder: (context, index) {
          final inv = _summary!.overdueInvoices[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.schedule, color: theme.colorScheme.error, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inv.contactName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('${inv.invoiceNumber} • ${inv.daysOverdue} gün gecikmiş',
                          style: TextStyle(fontSize: 11, color: Colors.red.shade400)),
                    ],
                  ),
                ),
                Text('${inv.totalAmount.toStringAsFixed(0)} ${inv.currencyCode}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.error)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // STOCK ALERTS LIST
  // ═══════════════════════════════════════════════
  Widget _buildStockAlertsList(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.orange.withOpacity(0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _summary!.stockAlerts.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor),
        itemBuilder: (context, index) {
          final alert = _summary!.stockAlerts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.inventory_2, color: Colors.orange, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alert.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(alert.productCode, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: alert.currentStock <= 0 ? Colors.red.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Stok: ${alert.currentStock.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: alert.currentStock <= 0 ? Colors.red.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // RECENT INVOICES LIST
  // ═══════════════════════════════════════════════
  Widget _buildRecentInvoices(ThemeData theme) {
    final invoices = _summary?.recentInvoices ?? [];

    if (invoices.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Henüz fatura yok', style: TextStyle(color: Colors.grey))),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: invoices.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor),
        itemBuilder: (context, index) {
          final inv = invoices[index];
          String statusText;
          Color statusColor;
          switch (inv.status) {
            case 2: statusText = 'Ödenmiş'; statusColor = theme.colorScheme.secondary; break;
            case 5: statusText = 'Kesilmiş'; statusColor = const Color(0xFF3B82F6); break;
            case 6: statusText = 'Kesilecek'; statusColor = const Color(0xFFF59E0B); break;
            case 3: statusText = 'İptal'; statusColor = Colors.grey; break;
            default: statusText = 'Ödenmemiş'; statusColor = const Color(0xFFF59E0B);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inv.contactName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(inv.invoiceNumber, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(statusText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor)),
                ),
                const SizedBox(width: 8),
                Text('${inv.totalAmount.toStringAsFixed(0)} ${inv.currencyCode}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.primary)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // UPCOMING TRANSACTIONS
  // ═══════════════════════════════════════════════
  Widget _buildUpcomingTransactions(ThemeData theme) {
    final items = _summary?.upcomingItems ?? [];

    if (items.isEmpty) {
      return Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Yaklaşan işlem bulunmuyor', style: TextStyle(color: Colors.grey))),
        ),
      );
    }

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor),
        itemBuilder: (context, index) {
          final item = items[index];
          final color = item.isIncome ? theme.colorScheme.secondary : theme.colorScheme.error;
          final prefix = item.isIncome ? '+' : '-';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Icon(item.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(item.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Text('$prefix${item.amount.toStringAsFixed(0)}${item.currencySymbol}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          );
        },
      ),
    );
  }
}
