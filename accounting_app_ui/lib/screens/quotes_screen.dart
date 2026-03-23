import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/invoice.dart';
import '../services/auth_service.dart';
import '../services/invoice_service.dart';
import '../utils/invoice_pdf.dart';
import '../widgets/responsive_scaffold.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});
  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  List<Invoice> _quotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() => _isLoading = true);
    try {
      // 7 = Proforma
      final quotes = await _invoiceService.getInvoices(status: 7);
      setState(() { _quotes = quotes; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red[700]));
  }

  Future<void> _approveQuote(Invoice quote) async {
    try {
      // Convert to ToBeIssued (6) or Pending (1) based on type
      final newStatus = quote.type == 1 ? 6 : 1; 
      
      final h = <String, String>{'Content-Type': 'application/json'};
      final token = await AuthService().getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';

      final res = await http.put(
        Uri.parse('${ApiConfig.invoices}/${quote.id}/status'),
        headers: h,
        body: jsonEncode(newStatus),
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teklif onaylandı ve faturaya dönüştürüldü!'), backgroundColor: Colors.green),
        );
        _loadQuotes();
      } else {
        _showError('Durum güncellenemedi: ${res.statusCode}');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _deleteQuote(String id) async {
    final act = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sil'),
        content: const Text('Bu teklifi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil', style: TextStyle(color: Colors.red))),
        ],
      )
    );
    if (act != true) return;

    try {
      await _invoiceService.deleteInvoice(id);
      _loadQuotes();
    } catch (e) { _showError(e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ResponsiveScaffold(
      currentRoute: 'quotes',
      title: 'Teklifler (Proforma)',
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _quotes.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('Kayıtlı teklif bulunamadı', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ]))
          : RefreshIndicator(
              onRefresh: _loadQuotes,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _quotes.length,
                itemBuilder: (ctx, i) {
                  final quote = _quotes[i];
                  final isSales = quote.type == 1;
                  return Card(
                    elevation: 1, margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Row(children: [
                            CircleAvatar(backgroundColor: theme.colorScheme.primary.withOpacity(0.1), radius: 16,
                              child: Icon(Icons.description, size: 16, color: theme.colorScheme.primary)),
                            const SizedBox(width: 8),
                            Text(isSales ? 'Satış Teklifi' : 'Alış Teklifi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ]),
                          Text(quote.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                        ]),
                        const Divider(height: 16),
                        Text(quote.contactName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Row(children: [
                            const Icon(Icons.calendar_today, size: 12, color: Colors.grey), const SizedBox(width: 4),
                            Text('${quote.issueDate.day}/${quote.issueDate.month}/${quote.issueDate.year}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(width: 12),
                            const Icon(Icons.event_available, size: 12, color: Colors.grey), const SizedBox(width: 4),
                            Text('Geçerlilik: ${quote.dueDate.day}/${quote.dueDate.month}/${quote.dueDate.year}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ]),
                        ]),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${quote.currencyCode} ${quote.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary)),
                          Row(children: [
                            IconButton(
                              icon: const Icon(Icons.print, color: Colors.grey),
                              onPressed: () async {
                                try {
                                  final details = await _invoiceService.getInvoiceDetail(quote.id);
                                  generateAndPrintInvoicePdf(details);
                                } catch (e) { _showError('PDF oluşturulamadı: \$e'); }
                              },
                              tooltip: 'Yazdır/PDF',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteQuote(quote.id),
                              tooltip: 'Sil',
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _approveQuote(quote),
                              icon: const Icon(Icons.check_circle, size: 16),
                              label: const Text('Faturaya Çevir'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            ),
                          ]),
                        ]),
                      ]),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddQuoteDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Teklif'),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // ADD QUOTE DIALOG (Multi-Line)
  // ═══════════════════════════════════════════════
  void _showAddQuoteDialog(BuildContext context) async {
    List<Map<String, dynamic>> contacts = [];
    List<Map<String, dynamic>> products = [];
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      final token = await AuthService().getToken();
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
    final dueCtrl = TextEditingController(text: DateTime.now().add(const Duration(days: 15)).toString().substring(0, 10)); // Quotes usually 15 days validity
    int selectedType = 1; // Quotes are usually for Sales (Giden)
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
            title: const Text('Yeni Teklif (Proforma)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: ChoiceChip(label: const Text('Satış Teklifi', style: TextStyle(fontSize: 12)), selected: selectedType == 1,
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2), onSelected: (_) => setDialogState(() => selectedType = 1))),
                      const SizedBox(width: 8),
                      Expanded(child: ChoiceChip(label: const Text('Alış Teklifi', style: TextStyle(fontSize: 12)), selected: selectedType == 2,
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2), onSelected: (_) => setDialogState(() => selectedType = 2))),
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
                      Expanded(child: TextFormField(controller: dueCtrl, decoration: const InputDecoration(labelText: 'Geçerlilik', isDense: true, border: OutlineInputBorder()))),
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
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade200)),
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

                    // Status: 7 -> Proforma (Teklif)
                    await _invoiceService.createInvoice({
                      'businessContactId': selectedContactId, 'type': selectedType,
                      'issueDate': '${issueCtrl.text}T00:00:00Z', 'dueDate': '${dueCtrl.text}T00:00:00Z',
                      'currencyId': selectedCurrencyId, 'exchangeRate': 1.0, 'waybillNumber': '', 'paymentTerms': '', 
                      'status': 7, 'lines': lines,
                    });

                    if (mounted) Navigator.pop(ctx);
                    _loadQuotes();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teklif oluşturuldu'), backgroundColor: Colors.green));
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
