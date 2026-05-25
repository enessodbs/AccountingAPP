import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../models/invoice.dart';
import '../services/auth_service.dart';
import '../services/invoice_service.dart';
import '../widgets/responsive_scaffold.dart';

/// Geçmiş dönem faturaları, tarih aralığı ve gelir/gider filtresi; dönem ve yıl net karı.
class IncomeExpenseTableScreen extends StatefulWidget {
  const IncomeExpenseTableScreen({super.key});

  @override
  State<IncomeExpenseTableScreen> createState() => _IncomeExpenseTableScreenState();
}

class _IncomeExpenseTableScreenState extends State<IncomeExpenseTableScreen> {
  final InvoiceService _invoiceService = InvoiceService();

  late DateTime _fromDate;
  late DateTime _toDate;
  /// -1: tümü, 1: gelir (satış), 2: gider (alış)
  int _typeFilter = -1;

  List<Invoice> _invoicesInRange = [];
  double _yearNetProfit = 0;
  bool _loading = true;
  String? _error;

  static DateTime _firstDayOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static DateTime _lastDayOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

  static DateTime _previousMonthStart() {
    final n = DateTime.now();
    if (n.month == 1) return DateTime(n.year - 1, 12, 1);
    return DateTime(n.year, n.month - 1, 1);
  }

  @override
  void initState() {
    super.initState();
    final start = _previousMonthStart();
    _fromDate = start;
    _toDate = DateTime(start.year, start.month + 1, 0);
    _load();
  }

  Future<Map<String, String>> _headers() async {
    final h = <String, String>{'Content-Type': 'application/json'};
    final token = await AuthService().getToken();
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final invoices = await _invoiceService.getInvoices(
        fromDate: _fromDate,
        toDate: _toDate,
        excludeCancelled: true,
      );
      final year = _toDate.year;
      final h = await _headers();
      final pl = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reports/profit-loss?year=$year'),
        headers: h,
      );
      double yearNet = 0;
      if (pl.statusCode == 200) {
        final map = jsonDecode(pl.body) as Map<String, dynamic>;
        yearNet = (map['totalProfit'] ?? 0).toDouble();
      }
      if (!mounted) return;
      setState(() {
        _invoicesInRange = invoices;
        _yearNetProfit = yearNet;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  List<Invoice> get _filteredInvoices {
    var list = List<Invoice>.from(_invoicesInRange);
    if (_typeFilter == 1) {
      list = list.where((i) => i.type == 1).toList();
    } else if (_typeFilter == 2) {
      list = list.where((i) => i.type == 2).toList();
    }
    list.sort((a, b) => b.issueDate.compareTo(a.issueDate));
    return list;
  }

  /// Seçili tarih aralığında iptal hariç net kar — profit-loss raporu ile aynı mantık (excludeCancelled).
  double get _periodNetProfit {
    double income = 0;
    double expense = 0;
    for (final i in _invoicesInRange) {
      if (i.type == 1) {
        income += i.totalAmount;
      } else if (i.type == 2) {
        expense += i.totalAmount;
      }
    }
    return income - expense;
  }

  String _fmt(double v) {
    if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(2);
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _pickFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d == null || !mounted) return;
    setState(() {
      _fromDate = d;
      if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
    });
    await _load();
  }

  Future<void> _pickTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime(2100),
    );
    if (d == null || !mounted) return;
    setState(() => _toDate = d);
    await _load();
  }

  void _applyPreviousMonth() {
    final start = _previousMonthStart();
    setState(() {
      _fromDate = start;
      _toDate = DateTime(start.year, start.month + 1, 0);
    });
    _load();
  }

  void _applyCurrentMonth() {
    final n = DateTime.now();
    setState(() {
      _fromDate = _firstDayOfMonth(n);
      _toDate = _lastDayOfMonth(n);
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final periodNet = _periodNetProfit;

    return ResponsiveScaffold(
      currentRoute: 'incomeExpense',
      title: l.get('incomeExpenseTable'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 22),
          tooltip: l.get('refresh'),
          onPressed: _loading ? null : _load,
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _load,
                          child: Text(l.get('retryBtn')),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.get('incomeExpenseTableDesc'),
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _applyPreviousMonth,
                            icon: const Icon(Icons.history, size: 18),
                            label: Text(l.get('applyPreviousMonth')),
                          ),
                          OutlinedButton(
                            onPressed: _applyCurrentMonth,
                            child: Text(localeMonthLabel(DateTime.now(), l)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, c) {
                          final narrow = c.maxWidth < 520;
                          if (narrow) {
                            return Column(
                              children: [
                                _dateTile(theme, l.get('periodStart'), _fromDate, _pickFrom),
                                const SizedBox(height: 8),
                                _dateTile(theme, l.get('periodEnd'), _toDate, _pickTo),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: _dateTile(theme, l.get('periodStart'), _fromDate, _pickFrom)),
                              const SizedBox(width: 12),
                              Expanded(child: _dateTile(theme, l.get('periodEnd'), _toDate, _pickTo)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<int>(
                        segments: [
                          ButtonSegment<int>(
                            value: -1,
                            label: Text(l.get('typeFilterAll')),
                            icon: const Icon(Icons.list_alt, size: 18),
                          ),
                          ButtonSegment<int>(
                            value: 1,
                            label: Text(l.get('typeFilterIncome')),
                            icon: const Icon(Icons.trending_up, size: 18),
                          ),
                          ButtonSegment<int>(
                            value: 2,
                            label: Text(l.get('typeFilterExpense')),
                            icon: const Icon(Icons.trending_down, size: 18),
                          ),
                        ],
                        selected: {_typeFilter},
                        onSelectionChanged: (Set<int> s) {
                          setState(() => _typeFilter = s.first);
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, c) {
                          final cards = [
                            _summaryCard(
                              theme,
                              l.get('monthNetProfit'),
                              '₺${_fmt(periodNet)}',
                              periodNet >= 0 ? Colors.teal : Colors.red,
                              Icons.calendar_month,
                            ),
                            _summaryCard(
                              theme,
                              '${l.get('yearNetProfit')} (${_toDate.year})',
                              '₺${_fmt(_yearNetProfit)}',
                              _yearNetProfit >= 0 ? Colors.indigo : Colors.red,
                              Icons.bar_chart,
                            ),
                          ];
                          if (c.maxWidth < 560) {
                            return Column(
                              children: [
                                cards[0],
                                const SizedBox(height: 8),
                                cards[1],
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: cards[0]),
                              const SizedBox(width: 8),
                              Expanded(child: cards[1]),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: theme.dividerColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _filteredInvoices.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Center(child: Text(l.get('noData'))),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Scrollbar(
                                      thumbVisibility: constraints.maxWidth < 700,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                          child: DataTable(
                                            headingRowHeight: 40,
                                            dataRowMinHeight: 40,
                                            dataRowMaxHeight: 48,
                                            columns: [
                                              DataColumn(label: Text(l.get('invoiceDate'))),
                                              DataColumn(label: Text(l.get('invoiceLabel'))),
                                              DataColumn(label: Text('${l.get('income')} / ${l.get('expense')}')),
                                              DataColumn(label: Text(l.get('invoiceAmount'))),
                                              DataColumn(label: Text(l.get('counterparty'))),
                                            ],
                                            rows: _filteredInvoices.map((inv) {
                                              final isIncome = inv.type == 1;
                                              return DataRow(
                                                cells: [
                                                  DataCell(Text(_formatDate(inv.issueDate))),
                                                  DataCell(
                                                    Text(
                                                      inv.invoiceNumber,
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                                                          size: 16,
                                                          color: isIncome ? Colors.green : Colors.red,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(isIncome ? l.get('income') : l.get('expense')),
                                                      ],
                                                    ),
                                                  ),
                                                  DataCell(Text('₺${_fmt(inv.totalAmount)} ${inv.currencyCode}')),
                                                  DataCell(Text(inv.contactName, overflow: TextOverflow.ellipsis)),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String localeMonthLabel(DateTime d, AppLocalizations l) {
    if (l.locale.languageCode == 'tr') {
      const names = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
      return 'Bu ay (${names[d.month]})';
    }
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return 'This month (${names[d.month]})';
  }

  Widget _dateTile(ThemeData theme, String label, DateTime d, VoidCallback onTap) {
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.event, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.65))),
                    Text(
                      _formatDate(d),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_calendar, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(ThemeData theme, String title, String value, Color accent, IconData icon) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
