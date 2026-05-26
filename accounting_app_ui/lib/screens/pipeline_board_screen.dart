import 'package:flutter/material.dart';
import '../services/crm_service.dart';
import '../models/crm_models.dart';
import '../widgets/responsive_scaffold.dart';
import '../l10n/app_localizations.dart';
import '../services/transaction_service.dart';

class PipelineBoardScreen extends StatefulWidget {
  const PipelineBoardScreen({super.key});

  @override
  State<PipelineBoardScreen> createState() => _PipelineBoardScreenState();
}

class _PipelineBoardScreenState extends State<PipelineBoardScreen> {
  final CrmService _crmService = CrmService();
  List<PipelineBoardColumn> _columns = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBoard();
  }

  Future<void> _loadBoard() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final columns = await _crmService.getPipelineBoard();
      columns.sort((a, b) => a.stageOrder.compareTo(b.stageOrder));
      setState(() { _columns = columns; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _onDrop(OpportunityModel opp, int newStageId) async {
    if (opp.stageId == newStageId) return;
    try {
      await _crmService.moveOpportunity(opp.id, newStageId);
      await _loadBoard();
      // Removed snackbar to prevent blocking the UI
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      currentRoute: 'pipeline',
      title: l.get('pipeline'),
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBoard),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOpportunityDialog(context, theme, l),
        icon: const Icon(Icons.add),
        label: Text(l.get('newOpportunity')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadBoard, child: const Text('Tekrar Dene')),
                    ],
                  ),
                )
              : _columns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.view_kanban_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(l.get('noOpportunities'), style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBoard,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _columns
                              .map((col) => _buildColumn(col, theme, l))
                              .toList(),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildColumn(PipelineBoardColumn column, ThemeData theme, AppLocalizations l) {
    final stageColor = _parseColor(column.stageColor);
    final totalAmount = column.opportunities.fold<double>(0, (sum, o) => sum + o.amount);

    return DragTarget<OpportunityModel>(
      onWillAcceptWithDetails: (details) => details.data.stageId != column.stageId,
      onAcceptWithDetails: (details) => _onDrop(details.data, column.stageId),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 300,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: isHovering
                ? stageColor.withOpacity(0.08)
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering ? stageColor : theme.dividerColor.withOpacity(0.3),
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Color Strip ───
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: stageColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
              // ─── Header ───
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: stageColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        column.stageName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: stageColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${column.opportunities.length}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: stageColor),
                      ),
                    ),
                  ],
                ),
              ),
              // ─── Total Amount ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      '₺${_formatAmount(totalAmount)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Divider(height: 1),
              // ─── Cards ───
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 240,
                ),
                child: column.opportunities.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined, color: Colors.grey[300], size: 32),
                              const SizedBox(height: 8),
                              Text(
                                isHovering ? 'Buraya bırakın' : l.get('dragToMove'),
                                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: column.opportunities.length,
                        itemBuilder: (ctx, i) => _buildOpportunityCard(
                          column.opportunities[i], stageColor, theme,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpportunityCard(OpportunityModel opp, Color stageColor, ThemeData theme) {
    return LongPressDraggable<OpportunityModel>(
      data: opp,
      delay: const Duration(milliseconds: 200),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        child: Transform.rotate(
          angle: 0.03,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: stageColor, width: 1.5),
            ),
            child: _buildCardContent(opp, stageColor, theme),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCardWidget(opp, stageColor, theme),
      ),
      child: _buildCardWidget(opp, stageColor, theme),
    );
  }

  Widget _buildCardWidget(OpportunityModel opp, Color stageColor, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showOpportunityDetail(opp, stageColor, theme),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _buildCardContent(opp, stageColor, theme),
        ),
      ),
    );
  }

  Widget _buildCardContent(OpportunityModel opp, Color stageColor, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          opp.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Amount + Probability
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '₺${_formatAmount(opp.amount)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _probabilityColor(opp.probability).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '%${opp.probability}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _probabilityColor(opp.probability),
                ),
              ),
            ),
            const Spacer(),
            if (opp.isWon)
              const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
          ],
        ),
        const SizedBox(height: 8),
        // Contact + Date
        Row(
          children: [
            Icon(Icons.business, size: 12, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                opp.contactName,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (opp.expectedCloseDate != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 11, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                _formatDate(opp.expectedCloseDate!),
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
        // Owner
        const SizedBox(height: 6),
        Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: stageColor.withOpacity(0.2),
              child: Text(
                opp.ownerName.isNotEmpty ? opp.ownerName[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 10, color: stageColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                opp.ownerName,
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showOpportunityDetail(OpportunityModel opp, Color stageColor, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(color: stageColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(opp.title, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow(Icons.monetization_on, 'Tutar', '₺${_formatAmount(opp.amount)}'),
              _infoRow(Icons.percent, 'Olasılık', '%${opp.probability}'),
              _infoRow(Icons.business, 'Müşteri', opp.contactName),
              _infoRow(Icons.person, 'Sorumlu', opp.ownerName),
              _infoRow(Icons.view_kanban, 'Aşama', opp.stageName),
              if (opp.expectedCloseDate != null)
                _infoRow(Icons.calendar_today, 'Tahmini Kapanış', _formatDate(opp.expectedCloseDate!)),
              if (opp.sourceLeadCompany != null)
                _infoRow(Icons.source, 'Kaynak Lead', opp.sourceLeadCompany!),
              if (opp.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text('Açıklama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text(opp.description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ],
          ),
        ),
        actions: [
          if (!opp.isWon && opp.actualCloseDate == null) ...[
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _crmService.closeOpportunity(opp.id, true);
                _loadBoard();
              },
              child: const Text('✅ Kazandık', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _crmService.closeOpportunity(opp.id, false, lostReason: 'Fiyat');
                _loadBoard();
              },
              child: const Text('❌ Kaybettik', style: TextStyle(color: Colors.red)),
            ),
          ],
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat')),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  void _showCreateOpportunityDialog(BuildContext context, ThemeData theme, AppLocalizations l) {
    final titleCtl = TextEditingController();
    final amountCtl = TextEditingController();
    final descCtl = TextEditingController();
    int probability = 50;

    String? selectedContactId;
    List<BusinessContactItem> contacts = [];
    bool isLoadingContacts = true;
    bool hasLoadedContactsOnce = false;
    final transactionService = TransactionService();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          if (!hasLoadedContactsOnce) {
            hasLoadedContactsOnce = true;
            transactionService.getBusinessContacts().then((loaded) {
              if (ctx.mounted) {
                setDialogState(() {
                  contacts = loaded;
                  isLoadingContacts = false;
                });
              }
            }).catchError((_) {
              if (ctx.mounted) {
                setDialogState(() {
                  isLoadingContacts = false;
                });
              }
            });
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(l.get('newOpportunity')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtl,
                    decoration: InputDecoration(
                      labelText: 'Başlık',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Dropdown for Customer
                  isLoadingContacts
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedContactId,
                                decoration: InputDecoration(
                                  labelText: 'Müşteri',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: contacts.map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                )).toList(),
                                onChanged: (v) => setDialogState(() => selectedContactId = v),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_box, color: Colors.blue),
                              onPressed: () {
                                final nameCtrl = TextEditingController();
                                showDialog(
                                  context: ctx,
                                  builder: (innerCtx) => AlertDialog(
                                    title: const Text('Yeni Müşteri/İş Ortağı', style: TextStyle(fontSize: 14)),
                                    content: TextField(
                                      controller: nameCtrl,
                                      decoration: const InputDecoration(labelText: 'Müşteri Adı', isDense: true, border: OutlineInputBorder()),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(innerCtx), child: const Text('İptal')),
                                      FilledButton(
                                        onPressed: () async {
                                          if (nameCtrl.text.isEmpty) return;
                                          try {
                                            final newContact = await transactionService.createBusinessContact(nameCtrl.text, 1);
                                            Navigator.pop(innerCtx);
                                            setDialogState(() {
                                              contacts.add(newContact);
                                              selectedContactId = newContact.id;
                                            });
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                          }
                                        },
                                        child: const Text('Ekle'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountCtl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l.get('amount'),
                      prefixText: '₺ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l.get('probability')}: %$probability',
                          style: const TextStyle(fontSize: 12)),
                      Slider(
                        value: probability.toDouble(),
                        min: 0, max: 100, divisions: 20,
                        label: '%$probability',
                        onChanged: (v) => setDialogState(() => probability = v.round()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Açıklama',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
              FilledButton(
                onPressed: () async {
                  if (titleCtl.text.isEmpty || selectedContactId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen başlık ve müşteri seçin')));
                    return;
                  }
                  try {
                    await _crmService.createOpportunity({
                      'title': titleCtl.text,
                      'amount': double.tryParse(amountCtl.text) ?? 0,
                      'probability': probability,
                      'description': descCtl.text,
                      'stageId': _columns.isNotEmpty ? _columns.first.stageId : 1,
                      'contactId': selectedContactId,
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadBoard();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hata: $e')),
                      );
                    }
                  }
                },
                child: const Text('Oluştur'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Helpers ───

  Color _parseColor(String hex) {
    try {
      hex = hex.replaceFirst('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  Color _probabilityColor(int probability) {
    if (probability >= 70) return Colors.green;
    if (probability >= 40) return Colors.orange;
    return Colors.red;
  }

  String _formatAmount(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
