import '../widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import '../services/role_service.dart';
import '../services/currency_service.dart';
import '../widgets/responsive_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final RoleService _roleService = RoleService();
  final CurrencyService _currencyService = CurrencyService();
  
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _currencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _roleService.getRoles(),
        _currencyService.getCurrencies(),
      ]);
      setState(() {
        _roles = results[0] as List<Map<String, dynamic>>;
        _currencies = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomToast.showError(context, 'Hata: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentRoute: 'settings',
      title: 'Sistem Ayarları',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Roller Listesi
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Rol Yönetimi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle),
                                  color: Theme.of(context).colorScheme.primary,
                                  onPressed: () => _showAddRoleDialog(context),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: _roles.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final role = _roles[index];
                                return ListTile(
                                  leading: const Icon(Icons.security, color: Colors.blueGrey),
                                  title: Text(role['name']),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _confirmDeleteRole(role),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Dövizler Listesi
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Döviz Yönetimi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle),
                                  color: Theme.of(context).colorScheme.secondary,
                                  onPressed: () => _showAddCurrencyDialog(context),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: _currencies.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final curr = _currencies[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.shade100,
                                    child: Text(curr['symbol'] ?? '\$', style: TextStyle(color: Colors.green.shade800)),
                                  ),
                                  title: Text(curr['code']),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _confirmDeleteCurrency(curr),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showAddRoleDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Rol Ekle'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Rol Adı (Örn: Editör)'),
            validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _roleService.addRole(ctrl.text, []);
                  if (mounted) { Navigator.pop(ctx); _loadData(); }
                } catch (e) {
                  CustomToast.showSuccess(context, e.toString());
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRole(Map<String, dynamic> role) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rolü Sil'),
        content: Text('${role['name']} silinecek. Emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (res == true) {
      try {
        await _roleService.deleteRole(role['id']);
        _loadData();
      } catch (e) {
        if (mounted) CustomToast.showSuccess(context, e.toString());
      }
    }
  }

  void _showAddCurrencyDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final codeCtrl = TextEditingController();
    final symCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Döviz Ekle'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Döviz Kodu (Örn: GBP)'),
                validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: symCtrl,
                decoration: const InputDecoration(labelText: 'Sembol (Örn: £)'),
                validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _currencyService.addCurrency(codeCtrl.text.toUpperCase(), symCtrl.text);
                  if (mounted) { Navigator.pop(ctx); _loadData(); }
                } catch (e) {
                  CustomToast.showSuccess(context, e.toString());
                }
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCurrency(Map<String, dynamic> curr) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dövizi Sil'),
        content: Text('${curr['code']} silinecek. Emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (res == true) {
      try {
        await _currencyService.deleteCurrency(curr['id']);
        _loadData();
      } catch (e) {
        if (mounted) CustomToast.showSuccess(context, e.toString());
      }
    }
  }
}
