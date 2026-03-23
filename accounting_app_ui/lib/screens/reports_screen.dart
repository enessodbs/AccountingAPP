import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../widgets/responsive_scaffold.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _profitLoss;
  Map<String, dynamic>? _vat;
  Map<String, dynamic>? _aging;
  bool _isLoading = true;
  int _selectedYear = DateTime.now().year;

  static const _months = ['Oca','Şub','Mar','Nis','May','Haz','Tem','Ağu','Eyl','Eki','Kas','Ara'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  Future<Map<String, String>> _headers() async {
    final h = <String, String>{'Content-Type': 'application/json'};
    final token = await AuthService().getToken();
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final h = await _headers();
    try {
      final results = await Future.wait([
        http.get(Uri.parse('${ApiConfig.baseUrl}/reports/profit-loss?year=$_selectedYear'), headers: h),
        http.get(Uri.parse('${ApiConfig.baseUrl}/reports/vat?year=$_selectedYear'), headers: h),
        http.get(Uri.parse('${ApiConfig.baseUrl}/reports/aging'), headers: h),
      ]);
      setState(() {
        if (results[0].statusCode == 200) _profitLoss = jsonDecode(results[0].body);
        if (results[1].statusCode == 200) _vat = jsonDecode(results[1].body);
        if (results[2].statusCode == 200) _aging = jsonDecode(results[2].body);
        _isLoading = false;
      });
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ResponsiveScaffold(
      currentRoute: 'reports',
      title: 'Raporlar',
      actions: [
        PopupMenuButton<int>(
          icon: const Icon(Icons.calendar_today, size: 18),
          onSelected: (y) { _selectedYear = y; _loadAll(); },
          itemBuilder: (_) => [for (var y = DateTime.now().year; y >= 2020; y--) PopupMenuItem(value: y, child: Text('$y'))],
        ),
      ],
      bottom: TabBar(controller: _tabController, labelColor: Colors.white, unselectedLabelColor: Colors.white70,
        indicatorColor: theme.colorScheme.secondary,
        tabs: const [Tab(text: 'Kâr/Zarar'), Tab(text: 'KDV'), Tab(text: 'Yaşlandırma')]),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(controller: _tabController, children: [
            _buildProfitLossTab(theme),
            _buildVatTab(theme),
            _buildAgingTab(theme),
          ]),
    );
  }

  // ═══════════════════════════════════════════════
  // KÂR/ZARAR TAB
  // ═══════════════════════════════════════════════
  Widget _buildProfitLossTab(ThemeData theme) {
    if (_profitLoss == null) return const Center(child: Text('Veri yüklenemedi'));
    final monthly = (_profitLoss!['monthly'] as List?) ?? [];
    final totalIncome = (_profitLoss!['totalIncome'] ?? 0).toDouble();
    final totalExpense = (_profitLoss!['totalExpense'] ?? 0).toDouble();
    final totalProfit = (_profitLoss!['totalProfit'] ?? 0).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        // Summary
        Row(children: [
          _summaryCard('Toplam Gelir', '₺${_fmt(totalIncome)}', Colors.green, Icons.trending_up),
          const SizedBox(width: 8),
          _summaryCard('Toplam Gider', '₺${_fmt(totalExpense)}', Colors.red, Icons.trending_down),
          const SizedBox(width: 8),
          _summaryCard('Net Kâr', '₺${_fmt(totalProfit)}', totalProfit >= 0 ? Colors.blue : Colors.red, Icons.account_balance),
        ]),
        const SizedBox(height: 16),
        // Chart
        Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Aylık Kâr/Zarar ($_selectedYear)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: BarChart(BarChartData(
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
                      getTitlesWidget: (v, m) => SideTitleWidget(meta: m, child: Text(_months[v.toInt()], style: const TextStyle(fontSize: 9, color: Colors.grey))))),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(monthly.length, (i) {
                    final m = monthly[i];
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(toY: (m['income'] ?? 0).toDouble(), color: Colors.green.shade400, width: 6, borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
                      BarChartRodData(toY: (m['expense'] ?? 0).toDouble(), color: Colors.red.shade400, width: 6, borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
                    ]);
                  }),
                )),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _legendDot(Colors.green.shade400, 'Gelir'),
                const SizedBox(width: 16),
                _legendDot(Colors.red.shade400, 'Gider'),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        // Table
        Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3), 2: FlexColumnWidth(3), 3: FlexColumnWidth(3)},
              children: [
                TableRow(children: ['Ay', 'Gelir', 'Gider', 'Kâr'].map((t) => Padding(padding: const EdgeInsets.all(6),
                  child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))).toList()),
                ...monthly.map((m) => TableRow(children: [
                  Padding(padding: const EdgeInsets.all(4), child: Text(_months[(m['month'] ?? 1) - 1], style: const TextStyle(fontSize: 11))),
                  Padding(padding: const EdgeInsets.all(4), child: Text('₺${_fmt((m['income'] ?? 0).toDouble())}', style: const TextStyle(fontSize: 11, color: Colors.green))),
                  Padding(padding: const EdgeInsets.all(4), child: Text('₺${_fmt((m['expense'] ?? 0).toDouble())}', style: const TextStyle(fontSize: 11, color: Colors.red))),
                  Padding(padding: const EdgeInsets.all(4), child: Text('₺${_fmt((m['profit'] ?? 0).toDouble())}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: (m['profit'] ?? 0) >= 0 ? Colors.blue : Colors.red))),
                ])),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════
  // KDV TAB
  // ═══════════════════════════════════════════════
  Widget _buildVatTab(ThemeData theme) {
    if (_vat == null) return const Center(child: Text('Veri yüklenemedi'));
    final monthly = (_vat!['monthly'] as List?) ?? [];
    final totalCollected = (_vat!['totalCollected'] ?? 0).toDouble();
    final totalPaid = (_vat!['totalPaid'] ?? 0).toDouble();
    final totalNet = (_vat!['totalNet'] ?? 0).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          _summaryCard('Hesaplanan KDV', '₺${_fmt(totalCollected)}', Colors.blue, Icons.add_circle_outline),
          const SizedBox(width: 8),
          _summaryCard('İndirilecek KDV', '₺${_fmt(totalPaid)}', Colors.orange, Icons.remove_circle_outline),
          const SizedBox(width: 8),
          _summaryCard('Ödenecek KDV', '₺${_fmt(totalNet)}', totalNet >= 0 ? Colors.red : Colors.green, Icons.account_balance),
        ]),
        const SizedBox(height: 12),
        Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3), 2: FlexColumnWidth(3), 3: FlexColumnWidth(3)},
              children: [
                TableRow(children: ['Ay', 'Hesaplanan', 'İndirilecek', 'Net'].map((t) => Padding(padding: const EdgeInsets.all(6),
                  child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))).toList()),
                ...monthly.map((m) => TableRow(children: [
                  Padding(padding: const EdgeInsets.all(4), child: Text(_months[(m['month'] ?? 1) - 1], style: const TextStyle(fontSize: 11))),
                  Padding(padding: const EdgeInsets.all(4), child: Text('₺${_fmt((m['collected'] ?? 0).toDouble())}', style: const TextStyle(fontSize: 11, color: Colors.blue))),
                  Padding(padding: const EdgeInsets.all(4), child: Text('₺${_fmt((m['paid'] ?? 0).toDouble())}', style: const TextStyle(fontSize: 11, color: Colors.orange))),
                  Padding(padding: const EdgeInsets.all(4), child: Text('₺${_fmt((m['net'] ?? 0).toDouble())}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: (m['net'] ?? 0) >= 0 ? Colors.red : Colors.green))),
                ])),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════
  // YAŞLANDIRMA TAB
  // ═══════════════════════════════════════════════
  Widget _buildAgingTab(ThemeData theme) {
    if (_aging == null) return const Center(child: Text('Veri yüklenemedi'));
    final invoices = (_aging!['invoices'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        // Aging buckets
        Row(children: [
          _summaryCard('0-30 Gün', '₺${_fmt((_aging!['aging0_30'] ?? 0).toDouble())}', Colors.yellow.shade800, Icons.timer),
          const SizedBox(width: 6),
          _summaryCard('31-60 Gün', '₺${_fmt((_aging!['aging31_60'] ?? 0).toDouble())}', Colors.orange, Icons.timer),
          const SizedBox(width: 6),
          _summaryCard('61-90 Gün', '₺${_fmt((_aging!['aging61_90'] ?? 0).toDouble())}', Colors.deepOrange, Icons.timer),
          const SizedBox(width: 6),
          _summaryCard('90+ Gün', '₺${_fmt((_aging!['aging90Plus'] ?? 0).toDouble())}', Colors.red, Icons.warning),
        ]),
        const SizedBox(height: 12),
        // Invoice list
        if (invoices.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(32),
            child: Column(children: [Icon(Icons.check_circle, size: 48, color: Colors.green[300]), const SizedBox(height: 8),
              Text('Vadesi geçmiş fatura yok! 🎉', style: TextStyle(color: Colors.grey[600]))])))
        else
          ...invoices.map((inv) => Card(
            elevation: 0.3, margin: const EdgeInsets.only(bottom: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(backgroundColor: Colors.red.withOpacity(0.1), radius: 16,
                child: Text('${inv['daysOverdue']}', style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold))),
              title: Text(inv['invoiceNumber'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              subtitle: Text(inv['contactName'] ?? '', style: const TextStyle(fontSize: 11)),
              trailing: Text('₺${(inv['totalAmount'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red)),
            ),
          )),
      ]),
    );
  }

  // Helpers
  Widget _summaryCard(String title, String amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: Theme.of(context).dividerColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 12, color: color), const SizedBox(width: 3),
            Expanded(child: Text(title, style: TextStyle(fontSize: 9, color: Colors.grey[600]), overflow: TextOverflow.ellipsis))]),
          const SizedBox(height: 2),
          FittedBox(fit: BoxFit.scaleDown, child: Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color))),
        ]),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 10))]);
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(2);
  }
}
