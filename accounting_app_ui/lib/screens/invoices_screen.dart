import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/invoice.dart';
import '../services/auth_service.dart';
import '../services/invoice_service.dart';
import '../utils/invoice_pdf.dart';
import '../widgets/responsive_scaffold.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> with SingleTickerProviderStateMixin {
  final InvoiceService _invoiceService = InvoiceService();
  late TabController _tabController;

  // Gelen (Purchase) alt filtre: null=hepsi, 1=Ödenmemiş(Pending), 2=Ödenmiş(Paid)
  int? _gelenFilter;
  // Giden (Sales) alt filtre: null=hepsi, 6=Kesilecek(ToBeIssued), 5=Kesilmiş(Issued)
  int? _gidenFilter;

  List<Invoice> _gelenInvoices = [];
  List<Invoice> _gidenInvoices = [];
  bool _isLoadingGelen = true;
  bool _isLoadingGiden = true;
  DateTimeRange? _dateRange;

  List<Invoice> _filterByDate(List<Invoice> invoices) {
    if (_dateRange == null) return invoices;
    return invoices.where((inv) =>
        !inv.issueDate.isBefore(_dateRange!.start) &&
        !inv.issueDate.isAfter(_dateRange!.end.add(const Duration(days: 1)))).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGelen();
    _loadGiden();
  }

  Future<void> _loadGelen() async {
    setState(() => _isLoadingGelen = true);
    try {
      final invoices = await _invoiceService.getInvoices(type: 2, status: _gelenFilter);
      setState(() { _gelenInvoices = invoices; _isLoadingGelen = false; });
    } catch (e) {
      setState(() => _isLoadingGelen = false);
      if (mounted) _showError(e.toString());
    }
  }

  Future<void> _loadGiden() async {
    setState(() => _isLoadingGiden = true);
    try {
      final invoices = await _invoiceService.getInvoices(type: 1, status: _gidenFilter);
      setState(() { _gidenInvoices = invoices; _isLoadingGiden = false; });
    } catch (e) {
      setState(() => _isLoadingGiden = false);
      if (mounted) _showError(e.toString());
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg.replaceAll('Exception: ', '')), backgroundColor: Colors.red[700]),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      currentRoute: 'invoices',
      title: 'Faturalar',
      actions: [
        if (_dateRange != null)
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            tooltip: 'Filtreyi Temizle',
            onPressed: () => setState(() => _dateRange = null),
          ),
        IconButton(
          icon: const Icon(Icons.date_range),
          tooltip: 'Tarih Filtrele',
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              initialDateRange: _dateRange,
              locale: const Locale('tr'),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(primary: theme.colorScheme.primary),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) setState(() => _dateRange = picked);
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: theme.colorScheme.secondary,
        tabs: const [
          Tab(text: 'Gelen Faturalar'),
          Tab(text: 'Giden Faturalar'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGelenTab(theme),
          _buildGidenTab(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInvoiceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Fatura Ekle'),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // GELEN FATURALAR TAB
  // ═══════════════════════════════════════════════
  Widget _buildGelenTab(ThemeData theme) {
    return Column(
      children: [
        _buildFilterChips(
          selectedFilter: _gelenFilter,
          filters: const {null: 'Tümü', 1: 'Ödenmemiş', 2: 'Ödenmiş'},
          onSelected: (val) => setState(() { _gelenFilter = val; _loadGelen(); }),
          theme: theme,
        ),
        Expanded(child: _buildInvoiceList(_filterByDate(_gelenInvoices), _isLoadingGelen, theme, _loadGelen)),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  // GİDEN FATURALAR TAB
  // ═══════════════════════════════════════════════
  Widget _buildGidenTab(ThemeData theme) {
    return Column(
      children: [
        _buildFilterChips(
          selectedFilter: _gidenFilter,
          filters: const {null: 'Tümü', 6: 'Kesilecek', 5: 'Kesilmiş'},
          onSelected: (val) => setState(() { _gidenFilter = val; _loadGiden(); }),
          theme: theme,
        ),
        Expanded(child: _buildInvoiceList(_filterByDate(_gidenInvoices), _isLoadingGiden, theme, _loadGiden)),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  // FILTER CHIPS
  // ═══════════════════════════════════════════════
  Widget _buildFilterChips({
    required int? selectedFilter,
    required Map<int?, String> filters,
    required ValueChanged<int?> onSelected,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: filters.entries.map((entry) {
          final isSelected = selectedFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey[700])),
              selected: isSelected,
              selectedColor: theme.colorScheme.primary,
              backgroundColor: Colors.grey[100],
              onSelected: (_) => onSelected(entry.key),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // INVOICE LIST
  // ═══════════════════════════════════════════════
  Widget _buildInvoiceList(List<Invoice> invoices, bool isLoading, ThemeData theme, VoidCallback onRefresh) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Fatura bulunamadı.', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return Dismissible(
            key: Key(invoice.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) => _confirmDelete(context, invoice),
            child: _buildInvoiceCard(invoice, theme),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // INVOICE CARD
  // ═══════════════════════════════════════════════
  Widget _buildInvoiceCard(Invoice invoice, ThemeData theme) {
    Color statusColor;
    switch (invoice.status) {
      case 2: statusColor = theme.colorScheme.secondary; break; // Ödenmiş
      case 4: statusColor = theme.colorScheme.error; break;     // Gecikmiş
      case 3: statusColor = Colors.grey; break;                  // İptal
      case 5: statusColor = const Color(0xFF3B82F6); break;     // Kesilmiş
      case 6: statusColor = const Color(0xFFF59E0B); break;     // Kesilecek
      default: statusColor = const Color(0xFFF59E0B);           // Pending / Ödenmemiş
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showInvoiceDetail(context, invoice),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(invoice.contactName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(invoice.statusText,
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invoice.invoiceNumber, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '${invoice.issueDate.day.toString().padLeft(2, '0')}.${invoice.issueDate.month.toString().padLeft(2, '0')}.${invoice.issueDate.year}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  Text(
                    '${invoice.totalAmount.toStringAsFixed(2)} ${invoice.currencyCode}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // INVOICE DETAIL POPUP
  // ═══════════════════════════════════════════════
  void _showInvoiceDetail(BuildContext context, Invoice invoice) async {
    showDialog(
      context: context,
      builder: (ctx) {
        int currentStatus = invoice.status;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Determine available status transitions
            List<Map<String, dynamic>> statusOptions = [];
            if (invoice.type == 2) {
              // Gelen (Purchase): Ödenmemiş(1) ↔ Ödenmiş(2)
              statusOptions = [
                {'value': 1, 'label': 'Ödenmemiş', 'icon': Icons.hourglass_empty, 'color': const Color(0xFFF59E0B)},
                {'value': 2, 'label': 'Ödenmiş', 'icon': Icons.check_circle, 'color': Colors.green},
              ];
            } else {
              // Giden (Sales): Kesilecek(6) ↔ Kesilmiş(5)
              statusOptions = [
                {'value': 6, 'label': 'Kesilecek', 'icon': Icons.schedule, 'color': const Color(0xFFF59E0B)},
                {'value': 5, 'label': 'Kesilmiş', 'icon': Icons.task_alt, 'color': const Color(0xFF3B82F6)},
              ];
            }

            String currentStatusText;
            switch (currentStatus) {
              case 1: currentStatusText = 'Ödenmemiş'; break;
              case 2: currentStatusText = 'Ödenmiş'; break;
              case 3: currentStatusText = 'İptal'; break;
              case 4: currentStatusText = 'Gecikmiş'; break;
              case 5: currentStatusText = 'Kesilmiş'; break;
              case 6: currentStatusText = 'Kesilecek'; break;
              default: currentStatusText = 'Bilinmiyor';
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: FutureBuilder<InvoiceDetail>(
                future: _invoiceService.getInvoiceDetail(invoice.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    );
                  }
                  final detail = snapshot.data!;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(detail.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.picture_as_pdf, size: 20, color: Colors.red.shade700),
                                    tooltip: 'PDF',
                                    onPressed: () => generateAndPrintInvoicePdf(detail),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(),
                          _detailRow('İş Ortağı', detail.contactName),
                          if (detail.contactTaxNumber != null && detail.contactTaxNumber!.isNotEmpty)
                            _detailRow('Vergi No', detail.contactTaxNumber!),
                          if (detail.contactTaxOffice != null && detail.contactTaxOffice!.isNotEmpty)
                            _detailRow('Vergi Dairesi', detail.contactTaxOffice!),
                          if (detail.contactAddress != null && detail.contactAddress!.isNotEmpty)
                            _detailRow('Adres', detail.contactAddress!),
                          const SizedBox(height: 8),
                          _detailRow('Tür', detail.type == 1 ? 'Giden (Satış)' : 'Gelen (Alım)'),
                          _detailRow('Durum', currentStatusText),
                          _detailRow('Düzenleme', '${detail.issueDate.day.toString().padLeft(2, '0')}.${detail.issueDate.month.toString().padLeft(2, '0')}.${detail.issueDate.year}'),
                          _detailRow('Vade', '${detail.dueDate.day.toString().padLeft(2, '0')}.${detail.dueDate.month.toString().padLeft(2, '0')}.${detail.dueDate.year}'),
                          // Status Change Buttons
                          const SizedBox(height: 8),
                          Text('Durumu Değiştir', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(
                            children: statusOptions.map((opt) {
                              final isActive = currentStatus == opt['value'];
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: opt == statusOptions.last ? 0 : 8),
                                  child: OutlinedButton.icon(
                                    icon: Icon(opt['icon'] as IconData, size: 16,
                                        color: isActive ? Colors.white : (opt['color'] as Color)),
                                    label: Text(opt['label'] as String,
                                        style: TextStyle(fontSize: 11,
                                            color: isActive ? Colors.white : (opt['color'] as Color))),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: isActive ? (opt['color'] as Color) : null,
                                      side: BorderSide(color: opt['color'] as Color),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    onPressed: isActive ? null : () async {
                                      try {
                                        await _invoiceService.updateInvoiceStatus(
                                            invoice.id, opt['value'] as int);
                                        setDialogState(() => currentStatus = opt['value'] as int);
                                        _loadGelen();
                                        _loadGiden();
                                        if (mounted) {
                                          ScaffoldMessenger.of(this.context).showSnackBar(
                                            SnackBar(
                                              content: Text('Durum "${opt['label']}" olarak güncellendi'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        _showError(e.toString());
                                      }
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const Divider(),
                          Text('Kalemler', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 13)),
                          const SizedBox(height: 6),
                          ...detail.lines.map((line) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(line.productName, style: const TextStyle(fontSize: 12))),
                                Text('${line.quantity.toStringAsFixed(0)} x ${line.unitPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(width: 12),
                                Text('${line.lineTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Ara Toplam', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              Text('${detail.subTotal.toStringAsFixed(2)} ${detail.currencyCode}', style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('KDV', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              Text('${detail.taxAmount.toStringAsFixed(2)} ${detail.currencyCode}', style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Toplam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('${detail.totalAmount.toStringAsFixed(2)} ${detail.currencyCode}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // DELETE CONFIRM
  // ═══════════════════════════════════════════════
  Future<bool> _confirmDelete(BuildContext context, Invoice invoice) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Faturayı Sil', style: TextStyle(fontSize: 16)),
        content: Text('${invoice.invoiceNumber} numaralı fatura silinecek. Onaylıyor musunuz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _invoiceService.deleteInvoice(invoice.id);
        _loadGelen();
        _loadGiden();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fatura silindi'), backgroundColor: Colors.green),
          );
        }
        return true;
      } catch (e) {
        _showError(e.toString());
        return false;
      }
    }
    return false;
  }

  // ═══════════════════════════════════════════════
  // ADD INVOICE DIALOG (Multi-Line)
  // ═══════════════════════════════════════════════
  void _showAddInvoiceDialog(BuildContext context) async {
    List<Map<String, dynamic>> contacts = [];
    List<Map<String, dynamic>> products = [];
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      final authService = AuthService();
      final token = await authService.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
      final contactsRes = await http.get(Uri.parse(ApiConfig.businessContacts), headers: headers);
      final productsRes = await http.get(Uri.parse(ApiConfig.products), headers: headers);
      if (contactsRes.statusCode == 200) contacts = (jsonDecode(contactsRes.body) as List).cast<Map<String, dynamic>>();
      if (productsRes.statusCode == 200) products = (jsonDecode(productsRes.body) as List).cast<Map<String, dynamic>>();
    } catch (e) {
      if (mounted) _showError('Veriler yüklenemedi: $e');
      return;
    }
    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final issueCtrl = TextEditingController(text: DateTime.now().toString().substring(0, 10));
    final dueCtrl = TextEditingController(text: DateTime.now().add(const Duration(days: 30)).toString().substring(0, 10));
    int selectedType = 2;
    int selectedCurrencyId = 1;
    String? selectedContactId = contacts.isNotEmpty ? contacts.first['id'].toString() : null;

    List<Map<String, dynamic>> invoiceLines = [
      {
        'productId': products.isNotEmpty ? products.first['id'] : null,
        'qtyCtrl': TextEditingController(text: '1'),
        'priceCtrl': TextEditingController(text: products.isNotEmpty ? (products.first['unitPrice'] ?? 0).toString() : ''),
        'taxRateCtrl': TextEditingController(text: '18'),
      }
    ];

    double calcSubTotal(List<Map<String, dynamic>> lines) {
      double s = 0;
      for (final l in lines) { s += (double.tryParse(l['qtyCtrl'].text) ?? 0) * (double.tryParse(l['priceCtrl'].text) ?? 0); }
      return s;
    }
    double calcTaxTotal(List<Map<String, dynamic>> lines) {
      double s = 0;
      for (final l in lines) { s += (double.tryParse(l['qtyCtrl'].text) ?? 0) * (double.tryParse(l['priceCtrl'].text) ?? 0) * ((double.tryParse(l['taxRateCtrl'].text) ?? 0) / 100); }
      return s;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setDialogState) {
          final subTotal = calcSubTotal(invoiceLines);
          final taxTotal = calcTaxTotal(invoiceLines);
          final grandTotal = subTotal + taxTotal;

          return AlertDialog(
            title: const Text('Yeni Fatura', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: ChoiceChip(label: const Text('Gelen (Alım)', style: TextStyle(fontSize: 12)), selected: selectedType == 2,
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2), onSelected: (_) => setDialogState(() => selectedType = 2))),
                      const SizedBox(width: 8),
                      Expanded(child: ChoiceChip(label: const Text('Giden (Satış)', style: TextStyle(fontSize: 12)), selected: selectedType == 1,
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2), onSelected: (_) => setDialogState(() => selectedType = 1))),
                    ]),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedContactId,
                      decoration: const InputDecoration(labelText: 'İş Ortağı', isDense: true, border: OutlineInputBorder()),
                      items: contacts.map((c) => DropdownMenuItem<String>(value: c['id'].toString(),
                        child: Text(c['name'] ?? '', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setDialogState(() => selectedContactId = v),
                      validator: (v) => v == null ? 'Zorunlu' : null,
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: TextFormField(controller: issueCtrl, decoration: const InputDecoration(labelText: 'Düzenleme', isDense: true, border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextFormField(controller: dueCtrl, decoration: const InputDecoration(labelText: 'Vade', isDense: true, border: OutlineInputBorder()))),
                    ]),
                    const Divider(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Kalemler', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      TextButton.icon(
                        icon: const Icon(Icons.add_circle, size: 18),
                        label: const Text('Kalem Ekle', style: TextStyle(fontSize: 12)),
                        onPressed: () => setDialogState(() => invoiceLines.add({
                          'productId': products.isNotEmpty ? products.first['id'] : null,
                          'qtyCtrl': TextEditingController(text: '1'),
                          'priceCtrl': TextEditingController(text: products.isNotEmpty ? (products.first['unitPrice'] ?? 0).toString() : ''),
                          'taxRateCtrl': TextEditingController(text: '18'),
                        })),
                      ),
                    ]),
                    ...invoiceLines.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final line = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.05), borderRadius: BorderRadius.circular(6), border: Border.all(color: Theme.of(context).dividerColor)),
                        child: Column(children: [
                          Row(children: [
                            Expanded(child: DropdownButtonFormField<int>(
                              value: line['productId'], isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Ürün', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                              items: products.map((p) => DropdownMenuItem<int>(value: p['id'],
                                child: Text('${p['code']} - ${p['name']}', style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (v) => setDialogState(() {
                                line['productId'] = v;
                                final prod = products.firstWhere((p) => p['id'] == v, orElse: () => {});
                                if (prod.isNotEmpty) line['priceCtrl'].text = (prod['unitPrice'] ?? 0).toString();
                              }),
                              validator: (v) => v == null ? 'Zorunlu' : null,
                            )),
                            if (invoiceLines.length > 1) IconButton(
                              icon: Icon(Icons.remove_circle, color: Colors.red.shade400, size: 20),
                              constraints: const BoxConstraints(), padding: const EdgeInsets.only(left: 4),
                              onPressed: () => setDialogState(() => invoiceLines.removeAt(idx)),
                            ),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            Expanded(flex: 2, child: TextFormField(controller: line['qtyCtrl'],
                              decoration: const InputDecoration(labelText: 'Adet', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                              keyboardType: TextInputType.number, style: const TextStyle(fontSize: 12), onChanged: (_) => setDialogState(() {}))),
                            const SizedBox(width: 6),
                            Expanded(flex: 3, child: TextFormField(controller: line['priceCtrl'],
                              decoration: const InputDecoration(labelText: 'Birim Fiyat', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                              keyboardType: TextInputType.number, style: const TextStyle(fontSize: 12),
                              validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null, onChanged: (_) => setDialogState(() {}))),
                            const SizedBox(width: 6),
                            SizedBox(width: 50, child: TextFormField(controller: line['taxRateCtrl'],
                              decoration: const InputDecoration(labelText: 'KDV%', isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8)),
                              keyboardType: TextInputType.number, style: const TextStyle(fontSize: 12), onChanged: (_) => setDialogState(() {}))),
                          ]),
                        ]),
                      );
                    }),
                    const Divider(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Ara Toplam', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('₺${subTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ]),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('KDV', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('₺${taxTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ]),
                        const Divider(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('GENEL TOPLAM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('₺${grandTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        ]),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  try {
                    final lines = invoiceLines.map((l) => {
                      'productId': l['productId'],
                      'quantity': int.tryParse(l['qtyCtrl'].text) ?? 1,
                      'unitPrice': double.tryParse(l['priceCtrl'].text) ?? 0,
                      'taxRate': double.tryParse(l['taxRateCtrl'].text) ?? 18,
                    }).toList();
                    await _invoiceService.createInvoice({
                      'businessContactId': selectedContactId, 'type': selectedType,
                      'issueDate': '${issueCtrl.text}T00:00:00Z', 'dueDate': '${dueCtrl.text}T00:00:00Z',
                      'currencyId': selectedCurrencyId, 'exchangeRate': 1.0, 'waybillNumber': '', 'paymentTerms': '', 'lines': lines,
                    });
                    if (mounted) Navigator.pop(ctx);
                    _loadGelen(); _loadGiden();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fatura oluşturuldu'), backgroundColor: Colors.green));
                  } catch (e) { _showError(e.toString()); }
                },
                child: const Text('Oluştur'),
              ),
            ],
          );
        });
      },
    );
  }
}
