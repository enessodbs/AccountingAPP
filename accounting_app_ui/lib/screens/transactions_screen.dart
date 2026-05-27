import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../widgets/responsive_scaffold.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();
  late TabController _tabController;

  List<Transaction> _allTx = [];
  List<Transaction> _collections = [];
  List<Transaction> _payments = [];
  bool _isLoadingAll = true;
  bool _isLoadingCol = true;
  bool _isLoadingPay = true;

  // Dropdown lookup için
  List<BusinessContactItem> _contacts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
    _loadContacts();
  }

  Future<void> _loadAll() async {
    _loadTab(null);
    _loadTab(1);
    _loadTab(2);
  }

  Future<void> _loadTab(int? type) async {
    if (type == null) setState(() => _isLoadingAll = true);
    if (type == 1) setState(() => _isLoadingCol = true);
    if (type == 2) setState(() => _isLoadingPay = true);

    try {
      final txs = await _transactionService.getTransactions(type: type);
      setState(() {
        if (type == null) { _allTx = txs; _isLoadingAll = false; }
        if (type == 1) { _collections = txs; _isLoadingCol = false; }
        if (type == 2) { _payments = txs; _isLoadingPay = false; }
      });
    } catch (e) {
      setState(() {
        if (type == null) _isLoadingAll = false;
        if (type == 1) _isLoadingCol = false;
        if (type == 2) _isLoadingPay = false;
      });
      if (mounted) _showError(e.toString());
    }
  }

  Future<void> _loadContacts() async {
    try {
      _contacts = await _transactionService.getBusinessContacts();
    } catch (_) {}
  }

  void _showError(String msg) {
    if (!mounted) return;
    CustomToast.showError(context, msg.replaceAll('Exception: ', ''));
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
      currentRoute: 'transactions',
      title: 'İşlemler',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: theme.colorScheme.secondary,
        tabs: const [
          Tab(text: 'Tümü'),
          Tab(text: 'Tahsilatlar'),
          Tab(text: 'Ödemeler'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(_allTx, _isLoadingAll, theme),
          _buildTransactionList(_collections, _isLoadingCol, theme),
          _buildTransactionList(_payments, _isLoadingPay, theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('İşlem Ekle'),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // TRANSACTION LIST
  // ═══════════════════════════════════════════════
  Widget _buildTransactionList(List<Transaction> txs, bool isLoading, ThemeData theme) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (txs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Kayıtlı işlem bulunamadı.', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadAll(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: txs.length,
        itemBuilder: (context, index) {
          final tx = txs[index];
          return Dismissible(
            key: Key(tx.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) => _confirmDelete(tx),
            child: _buildTransactionCard(tx, theme),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // TRANSACTION CARD
  // ═══════════════════════════════════════════════
  Widget _buildTransactionCard(Transaction tx, ThemeData theme) {
    final color = tx.isIncome ? theme.colorScheme.secondary : theme.colorScheme.error;
    final prefix = tx.isIncome ? '+' : '-';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showTransactionDetail(tx, theme),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  tx.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.businessContactName ?? tx.description ?? tx.typeText,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${tx.date.day.toString().padLeft(2, '0')}.${tx.date.month.toString().padLeft(2, '0')}.${tx.date.year}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(tx.paymentMethodText, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ),
                        if (tx.invoiceNumber != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(tx.invoiceNumber!, style: TextStyle(fontSize: 10, color: theme.colorScheme.primary)),
                          ),
                        ],
                      ],
                    ),
                    if (tx.description != null && tx.description!.isNotEmpty && tx.businessContactName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(tx.description!, style: const TextStyle(fontSize: 11, color: Colors.grey),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$prefix${tx.amount.toStringAsFixed(2)} ${tx.currencySymbol}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // TRANSACTION DETAIL POPUP
  // ═══════════════════════════════════════════════
  void _showTransactionDetail(Transaction tx, ThemeData theme) {
    final color = tx.isIncome ? theme.colorScheme.secondary : theme.colorScheme.error;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Icon(tx.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(tx.typeText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                _detailRow('Tutar', '${tx.amount.toStringAsFixed(2)} ${tx.currencySymbol}'),
                if (tx.businessContactName != null) _detailRow('İş Ortağı', tx.businessContactName!),
                _detailRow('Tarih', '${tx.date.day.toString().padLeft(2, '0')}.${tx.date.month.toString().padLeft(2, '0')}.${tx.date.year}'),
                _detailRow('Ödeme Yöntemi', tx.paymentMethodText),
                if (tx.invoiceNumber != null) _detailRow('Fatura No', tx.invoiceNumber!),
                if (tx.description != null && tx.description!.isNotEmpty)
                  _detailRow('Açıklama', tx.description!),
                if (tx.exchangeRate != 1.0)
                  _detailRow('Döviz Kuru', tx.exchangeRate.toStringAsFixed(4)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmDelete(tx);
                      },
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      label: const Text('Sil', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
  Future<bool> _confirmDelete(Transaction tx) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İşlemi Sil', style: TextStyle(fontSize: 16)),
        content: Text('${tx.typeText} işlemi (${tx.amount.toStringAsFixed(2)} ${tx.currencySymbol}) silinecek. Onaylıyor musunuz?'),
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
        await _transactionService.deleteTransaction(tx.id);
        _loadAll();
        if (mounted) {
          CustomToast.showSuccess(context, 'İşlem silindi');
        }
        return true;
      } catch (e) {
        _showError(e.toString());
      }
    }
    return false;
  }

  // ═══════════════════════════════════════════════
  // ADD TRANSACTION DIALOG
  // ═══════════════════════════════════════════════
  void _showAddTransactionDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toString().substring(0, 10));

    int selectedType = 1; // 1: Tahsilat, 2: Ödeme
    int selectedPaymentMethod = 1; // 1: Nakit, 2: Havale, 3: Kredi Kartı
    String? selectedContactId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Yeni İşlem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // İşlem Türü
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_downward_rounded, size: 14,
                                      color: selectedType == 1 ? Colors.white : Colors.green),
                                  const SizedBox(width: 4),
                                  Text('Tahsilat', style: TextStyle(fontSize: 12,
                                      color: selectedType == 1 ? Colors.white : Colors.black87)),
                                ],
                              ),
                              selected: selectedType == 1,
                              selectedColor: Theme.of(context).colorScheme.secondary,
                              onSelected: (_) => setDialogState(() => selectedType = 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_upward_rounded, size: 14,
                                      color: selectedType == 2 ? Colors.white : Colors.red),
                                  const SizedBox(width: 4),
                                  Text('Ödeme', style: TextStyle(fontSize: 12,
                                      color: selectedType == 2 ? Colors.white : Colors.black87)),
                                ],
                              ),
                              selected: selectedType == 2,
                              selectedColor: Theme.of(context).colorScheme.error,
                              onSelected: (_) => setDialogState(() => selectedType = 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tutar
                      TextFormField(
                        controller: amountCtrl,
                        decoration: const InputDecoration(labelText: 'Tutar (₺)', isDense: true, border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money, size: 18)),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Zorunlu';
                          if ((double.tryParse(v) ?? 0) <= 0) return 'Geçerli bir tutar girin';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Tarih
                      TextFormField(
                        controller: dateCtrl,
                        decoration: const InputDecoration(labelText: 'Tarih (YYYY-AA-GG)', isDense: true, border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today, size: 18)),
                        validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
                      ),
                      const SizedBox(height: 8),

                      // İş Ortağı (API'den)
                      DropdownButtonFormField<String>(
                        value: selectedContactId,
                        decoration: const InputDecoration(labelText: 'İş Ortağı', isDense: true, border: OutlineInputBorder()),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('(Seçmeden devam et)', style: TextStyle(fontSize: 13, color: Colors.grey))),
                          ..._contacts.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.name} (${c.typeText})', style: const TextStyle(fontSize: 13)),
                          )),
                        ],
                        onChanged: (v) => setDialogState(() => selectedContactId = v),
                      ),
                      const SizedBox(height: 8),

                      // Ödeme Yöntemi
                      DropdownButtonFormField<int>(
                        value: selectedPaymentMethod,
                        decoration: const InputDecoration(labelText: 'Ödeme Yöntemi', isDense: true, border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 1, child: Row(children: [
                            Icon(Icons.payments_outlined, size: 16, color: Colors.grey), SizedBox(width: 8),
                            Text('Nakit', style: TextStyle(fontSize: 13)),
                          ])),
                          DropdownMenuItem(value: 2, child: Row(children: [
                            Icon(Icons.account_balance_outlined, size: 16, color: Colors.grey), SizedBox(width: 8),
                            Text('Havale/EFT', style: TextStyle(fontSize: 13)),
                          ])),
                          DropdownMenuItem(value: 3, child: Row(children: [
                            Icon(Icons.credit_card_outlined, size: 16, color: Colors.grey), SizedBox(width: 8),
                            Text('Kredi Kartı', style: TextStyle(fontSize: 13)),
                          ])),
                        ],
                        onChanged: (v) => setDialogState(() => selectedPaymentMethod = v ?? 1),
                      ),
                      const SizedBox(height: 8),

                      // Açıklama
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Açıklama', isDense: true, border: OutlineInputBorder()),
                        maxLines: 2,
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
                      await _transactionService.createTransaction({
                        'type': selectedType,
                        'amount': double.tryParse(amountCtrl.text) ?? 0,
                        'currencyId': 1,
                        'exchangeRate': 1.0,
                        'date': '${dateCtrl.text}T00:00:00Z',
                        'paymentMethod': selectedPaymentMethod,
                        'description': descCtrl.text.trim(),
                        if (selectedContactId != null) 'businessContactId': selectedContactId,
                      });
                      if (mounted) Navigator.pop(ctx);
                      _loadAll();
                      if (mounted) {
                        CustomToast.showSuccess(context, selectedType == 1 ? 'Tahsilat oluşturuldu' : 'Ödeme oluşturuldu');
                      }
                    } catch (e) {
                      _showError(e.toString());
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
