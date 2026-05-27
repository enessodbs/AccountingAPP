import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/crm_models.dart';
import '../services/crm_service.dart';
import '../widgets/responsive_scaffold.dart';
import '../services/transaction_service.dart';
import '../l10n/app_localizations.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final CrmService _crmService = CrmService();
  List<LeadModel> _leads = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filters
  int? _selectedStatus;
  int? _selectedSource;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Status options
  static const List<Map<String, dynamic>> _statusOptions = [
    {'value': 0, 'label': 'Yeni', 'color': Colors.blue},
    {'value': 1, 'label': 'İletişime Geçildi', 'color': Colors.orange},
    {'value': 2, 'label': 'Nitelikli', 'color': Colors.green},
    {'value': 3, 'label': 'Niteliksiz', 'color': Colors.grey},
    {'value': 4, 'label': 'Dönüştürüldü', 'color': Colors.purple},
    {'value': 5, 'label': 'Kaybedildi', 'color': Colors.red},
  ];

  // Source options
  static const List<Map<String, dynamic>> _sourceOptions = [
    {'value': 0, 'label': 'Web Sitesi'},
    {'value': 1, 'label': 'Referans'},
    {'value': 2, 'label': 'Sosyal Medya'},
    {'value': 3, 'label': 'E-posta'},
    {'value': 4, 'label': 'Telefon'},
    {'value': 5, 'label': 'Fuar'},
    {'value': 6, 'label': 'Diğer'},
  ];

  Color _getStatusColor(int status) {
    switch (status) {
      case 0: return Colors.blue;
      case 1: return Colors.orange;
      case 2: return Colors.green;
      case 3: return Colors.grey;
      case 4: return Colors.purple;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final leads = await _crmService.getLeads(
        status: _selectedStatus,
        source: _selectedSource,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      setState(() {
        _leads = leads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return ResponsiveScaffold(
      currentRoute: 'leads',
      title: l.get('leads'),
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
      ],
      body: Column(
        children: [
          // ─── Filter Bar ───
          _buildFilterBar(theme, l),
          // ─── Content ───
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorState(theme, l)
                    : _leads.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_search_rounded, size: 64,
                                    color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                const SizedBox(height: 12),
                                Text(l.get('noData'),
                                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _leads.length,
                              itemBuilder: (context, index) {
                                final lead = _leads[index];
                                return Dismissible(
                                  key: Key(lead.id),
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
                                  confirmDismiss: (_) => _confirmDelete(lead),
                                  child: _buildLeadCard(lead, theme, currencyFormat),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLeadDialog(context),
        icon: const Icon(Icons.person_add),
        label: Text(l.get('create')),
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          // Status filter
          Expanded(
            child: DropdownButtonFormField<int?>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Durum',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Tümü', style: TextStyle(fontSize: 13))),
                ..._statusOptions.map((s) => DropdownMenuItem<int?>(
                  value: s['value'] as int,
                  child: Text(s['label'] as String, style: const TextStyle(fontSize: 13)),
                )),
              ],
              onChanged: (v) {
                setState(() => _selectedStatus = v);
                _loadData();
              },
            ),
          ),
          const SizedBox(width: 8),
          // Source filter
          Expanded(
            child: DropdownButtonFormField<int?>(
              value: _selectedSource,
              decoration: InputDecoration(
                labelText: 'Kaynak',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Tümü', style: TextStyle(fontSize: 13))),
                ..._sourceOptions.map((s) => DropdownMenuItem<int?>(
                  value: s['value'] as int,
                  child: Text(s['label'] as String, style: const TextStyle(fontSize: 13)),
                )),
              ],
              onChanged: (v) {
                setState(() => _selectedSource = v);
                _loadData();
              },
            ),
          ),
          const SizedBox(width: 8),
          // Search
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l.get('search'),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _loadData();
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) {
                setState(() => _searchQuery = v);
                _loadData();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(l.get('retryBtn')),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(LeadModel lead, ThemeData theme, NumberFormat currencyFormat) {
    final statusColor = _getStatusColor(lead.status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showDetailDialog(lead),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Company name + Status chip
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.business_rounded, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lead.companyName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis),
                        if (lead.contactPerson.isNotEmpty)
                          Text(lead.contactPerson,
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lead.statusName.isNotEmpty ? lead.statusName : _getStatusLabel(lead.status),
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Row 2: Contact info
              Row(
                children: [
                  if (lead.email.isNotEmpty) ...[
                    Icon(Icons.email_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(lead.email,
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (lead.phone.isNotEmpty) ...[
                    Icon(Icons.phone_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(lead.phone,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Row 3: Source, Value, Score, AssignedTo
              Row(
                children: [
                  // Source chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      lead.sourceName.isNotEmpty ? lead.sourceName : _getSourceLabel(lead.source),
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Estimated value
                  Icon(Icons.attach_money, size: 14, color: Colors.green[600]),
                  Text(currencyFormat.format(lead.estimatedValue),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green[700])),
                  const Spacer(),
                  // Score bar
                  _buildScoreIndicator(lead.score, theme),
                  const SizedBox(width: 8),
                  // Assigned to
                  if (lead.assignedToName != null && lead.assignedToName!.isNotEmpty) ...[
                    Icon(Icons.person_outline, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(lead.assignedToName!,
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(int score, ThemeData theme) {
    final color = score >= 80
        ? Colors.green
        : score >= 50
            ? Colors.orange
            : Colors.red;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text('$score', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  String _getStatusLabel(int status) {
    if (status >= 0 && status < _statusOptions.length) {
      return _statusOptions[status]['label'] as String;
    }
    return 'Bilinmiyor';
  }

  String _getSourceLabel(int source) {
    if (source >= 0 && source < _sourceOptions.length) {
      return _sourceOptions[source]['label'] as String;
    }
    return 'Diğer';
  }

  Future<bool> _confirmDelete(LeadModel lead) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lead\'i Sil', style: TextStyle(fontSize: 16)),
        content: Text('"${lead.companyName}" silinecek. Onaylıyor musunuz?'),
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
        await _crmService.deleteLead(lead.id);
        _loadData();
        if (mounted) {
          CustomToast.showSuccess(context, 'Lead silindi');
        }
        return true;
      } catch (e) {
        if (mounted) {
          CustomToast.showError(context, e.toString());
        }
      }
    }
    return false;
  }

  void _showDetailDialog(LeadModel lead) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(lead.status);
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.business, color: statusColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(lead.companyName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(Icons.person, 'Kişi', lead.contactPerson),
              _detailRow(Icons.email, 'E-posta', lead.email),
              _detailRow(Icons.phone, 'Telefon', lead.phone),
              _detailRow(Icons.flag, 'Durum', lead.statusName.isNotEmpty ? lead.statusName : _getStatusLabel(lead.status)),
              _detailRow(Icons.source, 'Kaynak', lead.sourceName.isNotEmpty ? lead.sourceName : _getSourceLabel(lead.source)),
              _detailRow(Icons.attach_money, 'Tahmini Değer', currencyFormat.format(lead.estimatedValue)),
              _detailRow(Icons.score, 'Skor', '${lead.score}/100'),
              if (lead.assignedToName != null)
                _detailRow(Icons.person_pin, 'Atanan', lead.assignedToName!),
              _detailRow(Icons.calendar_today, 'Oluşturulma', DateFormat('dd.MM.yyyy HH:mm').format(lead.createdAt)),
            ],
          ),
        ),
        actions: [
          if (lead.status != 4 && lead.status != 5) // Not already Converted or Lost
            FilledButton.icon(
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Müşteri Olarak Onayla'),
              style: FilledButton.styleFrom(backgroundColor: Colors.green[700]),
              onPressed: () async {
                try {
                  // Müşteriye dönüştür (Convert endpoint'i kullanılarak tek adımda yapılır)
                  await _crmService.convertLead(lead.id);
                  
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    CustomToast.showSuccess(context, 'Tebrikler! Müşteri adayı başarıyla müşteriye (iş ortağına) dönüştürüldü.');
                  }
                  _loadData();
                } catch (e) {
                  if (mounted) {
                    CustomToast.showError(context, e.toString());
                  }
                }
              },
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat')),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  void _showAddLeadDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final companyCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    int selectedSource = 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Yeni Lead', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: companyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Firma Adı',
                          isDense: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business, size: 18),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: contactCtrl,
                        decoration: const InputDecoration(
                          labelText: 'İlgili Kişi',
                          isDense: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person, size: 18),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'E-posta',
                          isDense: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email, size: 18),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                              return 'Geçerli e-posta giriniz';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Telefon',
                          isDense: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone, size: 18),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[+]*[0-9]*')),
                        ],
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 10) {
                            return 'Geçerli telefon giriniz';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        value: selectedSource,
                        decoration: const InputDecoration(
                          labelText: 'Kaynak',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: _sourceOptions.map((s) => DropdownMenuItem<int>(
                          value: s['value'] as int,
                          child: Text(s['label'] as String, style: const TextStyle(fontSize: 13)),
                        )).toList(),
                        onChanged: (v) => setDialogState(() => selectedSource = v ?? 0),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: valueCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tahmini Değer (₺)',
                          isDense: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money, size: 18),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            if (double.tryParse(v.replaceAll(',', '.')) == null) {
                              return 'Geçerli bir sayı giriniz';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notlar',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    try {
                      final fullName = contactCtrl.text.trim();
                      final names = fullName.split(' ');
                      final firstName = names.length > 1 ? names.sublist(0, names.length - 1).join(' ') : fullName;
                      final lastName = names.length > 1 ? names.last : '-';

                      await _crmService.createLead({
                        'companyName': companyCtrl.text.trim(),
                        'firstName': firstName,
                        'lastName': lastName,
                        'email': emailCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'source': selectedSource,
                        'estimatedValue': double.tryParse(valueCtrl.text.replaceAll(',', '.')) ?? 0,
                        'notes': notesCtrl.text.trim(),
                      });
                      if (mounted) Navigator.pop(ctx);
                      _loadData();
                      if (mounted) {
                        CustomToast.showSuccess(context, 'Lead oluşturuldu');
                      }
                    } catch (e) {
                      if (mounted) {
                        CustomToast.showError(context, e.toString());
                      }
                    }
                  },
                  child: const Text('Oluştur'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
