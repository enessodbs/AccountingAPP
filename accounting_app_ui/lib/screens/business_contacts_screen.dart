import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../widgets/responsive_scaffold.dart';

class BusinessContactsScreen extends StatefulWidget {
  const BusinessContactsScreen({super.key});
  @override
  State<BusinessContactsScreen> createState() => _BusinessContactsScreenState();
}

class _BusinessContactsScreenState extends State<BusinessContactsScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() { super.initState(); _loadContacts(); }

  Future<Map<String, String>> _headers() async {
    final h = <String, String>{'Content-Type': 'application/json'};
    final token = await AuthService().getToken();
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse(ApiConfig.businessContacts), headers: await _headers());
      if (res.statusCode == 200) {
        setState(() { _contacts = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>(); _isLoading = false; });
      }
    } catch (e) { setState(() => _isLoading = false); }
  }

  List<Map<String, dynamic>> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    final q = _searchQuery.toLowerCase();
    return _contacts.where((c) => (c['name'] ?? '').toString().toLowerCase().contains(q) ||
      (c['taxNumber'] ?? '').toString().contains(q)).toList();
  }

  String _contactTypeName(int type) {
    switch (type) { case 1: return 'Müşteri'; case 2: return 'Tedarikçi'; default: return 'Diğer'; }
  }

  Color _contactTypeColor(int type) {
    switch (type) { case 1: return Colors.blue; case 2: return Colors.orange; default: return Colors.grey; }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ResponsiveScaffold(
      currentRoute: 'contacts',
      title: _isSearching ? '' : 'İş Ortakları',
      actions: [
        if (_isSearching)
          SizedBox(
            width: 200,
            child: TextField(autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'İş ortağı ara...', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none),
                onChanged: (v) => setState(() => _searchQuery = v)),
          ),
        IconButton(icon: Icon(_isSearching ? Icons.close : Icons.search), onPressed: () => setState(() { _isSearching = !_isSearching; if (!_isSearching) _searchQuery = ''; })),
      ],
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _filteredContacts.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.business, size: 48, color: Colors.grey[400]), const SizedBox(height: 12), Text('İş ortağı bulunamadı.', style: TextStyle(color: Colors.grey[500]))]))
          : RefreshIndicator(
              onRefresh: () async => _loadContacts(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _filteredContacts.length,
                itemBuilder: (ctx, i) {
                  final c = _filteredContacts[i];
                  final type = c['type'] ?? 3;
                  return Card(
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: _contactTypeColor(type).withOpacity(0.15),
                        child: Icon(Icons.business, color: _contactTypeColor(type), size: 20)),
                      title: Text(c['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(_contactTypeName(type), style: TextStyle(fontSize: 11, color: _contactTypeColor(type))),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactDetailScreen(contactId: c['id'], contactName: c['name'] ?? ''))),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ═══════════════════════════════════════════════
// CONTACT DETAIL SCREEN (Cari Hesap Ekstresi)
// ═══════════════════════════════════════════════
class ContactDetailScreen extends StatefulWidget {
  final String contactId;
  final String contactName;
  const ContactDetailScreen({super.key, required this.contactId, required this.contactName});
  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStatement();
  }

  Future<void> _loadStatement() async {
    setState(() => _isLoading = true);
    try {
      final h = <String, String>{'Content-Type': 'application/json'};
      final token = await AuthService().getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
      final res = await http.get(Uri.parse('${ApiConfig.businessContacts}/${widget.contactId}/statement'), headers: h);
      if (res.statusCode == 200) {
        setState(() { _data = jsonDecode(res.body); _isLoading = false; });
      }
    } catch (e) { setState(() => _isLoading = false); }
  }

  String _formatDate(String? d) {
    if (d == null) return '-';
    final dt = DateTime.tryParse(d);
    if (dt == null) return d;
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  String _statusText(int status) {
    switch (status) { case 1: return 'Ödenmemiş'; case 2: return 'Ödenmiş'; case 5: return 'Kesilmiş'; case 6: return 'Kesilecek'; default: return 'Diğer'; }
  }

  String _paymentMethodText(int method) {
    switch (method) { case 1: return 'Nakit'; case 2: return 'Havale/EFT'; case 3: return 'Kredi Kartı'; default: return 'Diğer'; }
  }

  Color _statusColor(int status) {
    switch (status) { case 2: case 5: return Colors.green; case 1: case 6: return Colors.orange; default: return Colors.grey; }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        bottom: TabBar(controller: _tabController, labelColor: Colors.white, unselectedLabelColor: Colors.white70,
          indicatorColor: theme.colorScheme.secondary, tabs: const [Tab(text: 'Faturalar'), Tab(text: 'Tahsilatlar')]),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _data == null
          ? const Center(child: Text('Veri bulunamadı'))
          : Column(children: [
              // Summary cards
              Container(
                padding: const EdgeInsets.all(12),
                color: theme.colorScheme.primary.withOpacity(0.05),
                child: Row(children: [
                  _buildSummaryCard('Toplam Fatura', '₺${(_data!['totalInvoiced'] ?? 0).toStringAsFixed(2)}', Colors.blue, Icons.receipt),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Toplam Ödeme', '₺${(_data!['totalPaid'] ?? 0).toStringAsFixed(2)}', Colors.green, Icons.payments),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Bakiye', '₺${(_data!['balance'] ?? 0).toStringAsFixed(2)}',
                    (_data!['balance'] ?? 0) > 0 ? Colors.red : Colors.green, Icons.account_balance_wallet),
                ]),
              ),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  _buildInvoicesList(),
                  _buildTransactionsList(),
                ]),
              ),
            ]),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4),
            Expanded(child: Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[600]), overflow: TextOverflow.ellipsis))]),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ]),
      ),
    );
  }

  Widget _buildInvoicesList() {
    final invoices = (_data!['invoices'] as List?) ?? [];
    if (invoices.isEmpty) return const Center(child: Text('Fatura bulunamadı', style: TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: invoices.length,
      itemBuilder: (ctx, i) {
        final inv = invoices[i];
        final status = inv['status'] ?? 0;
        return Card(
          elevation: 0.3, margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            dense: true,
            title: Text(inv['invoiceNumber'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text('${_formatDate(inv['issueDate'])} → ${_formatDate(inv['dueDate'])}', style: const TextStyle(fontSize: 11)),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('₺${(inv['totalAmount'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(_statusText(status), style: TextStyle(fontSize: 9, color: _statusColor(status), fontWeight: FontWeight.w600))),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList() {
    final txs = (_data!['transactions'] as List?) ?? [];
    if (txs.isEmpty) return const Center(child: Text('Tahsilat bulunamadı', style: TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: txs.length,
      itemBuilder: (ctx, i) {
        final tx = txs[i];
        final isCollection = (tx['type'] ?? 0) == 1;
        return Card(
          elevation: 0.3, margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(backgroundColor: (isCollection ? Colors.green : Colors.red).withOpacity(0.1), radius: 16,
              child: Icon(isCollection ? Icons.arrow_downward : Icons.arrow_upward, color: isCollection ? Colors.green : Colors.red, size: 16)),
            title: Text('₺${(tx['amount'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text('${_formatDate(tx['transactionDate'])} • ${tx['description'] ?? ''}', style: const TextStyle(fontSize: 11)),
            trailing: Text(_paymentMethodText(tx['paymentMethod'] ?? 1), style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ),
        );
      },
    );
  }
}
