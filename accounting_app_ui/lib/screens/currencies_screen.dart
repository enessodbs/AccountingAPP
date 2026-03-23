import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../widgets/responsive_scaffold.dart';

class CurrenciesScreen extends StatefulWidget {
  const CurrenciesScreen({super.key});
  @override
  State<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  List<Map<String, dynamic>> _rates = [];
  bool _isLoading = true;
  String _lastUpdate = '';

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() { _isLoading = true; _lastUpdate = ''; });
    try {
      final h = <String, String>{'Content-Type': 'application/json'};
      final token = await AuthService().getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';

      final res = await http.get(Uri.parse('${ApiConfig.currencies}/live-rates'), headers: h);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          _rates = data.cast<Map<String, dynamic>>();
          _lastUpdate = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showError('Kurlar alınamadı (Hata: ${res.statusCode})');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Bağlantı hatası: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ResponsiveScaffold(
      currentRoute: 'currencies',
      title: 'Döviz Kurları',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Kurları Güncelle',
          onPressed: _loadRates,
        ),
      ],
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.primary.withOpacity(0.1),
                child: Column(
                  children: [
                    Icon(Icons.currency_exchange, size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 8),
                    const Text('Canlı Döviz Kurları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Son Güncelleme: $_lastUpdate', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    const Text('TCMB referanslı açık API üzerinden alınmaktadır.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadRates,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _rates.length,
                    itemBuilder: (context, index) {
                      final rate = _rates[index];
                      final isTry = rate['code'] == 'TRY';
                      final val = (rate['rate'] ?? 0).toDouble();

                      return Card(
                        elevation: 0.5,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isTry ? Colors.red.withOpacity(0.1) : theme.colorScheme.secondary.withOpacity(0.1),
                            child: Text(rate['symbol'] ?? '', style: TextStyle(color: isTry ? Colors.red : theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(rate['code'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(isTry ? 'Türk Lirası (Baz Kur)' : '1 ${rate['code']} = ${val.toStringAsFixed(4)} ₺'),
                          trailing: isTry
                              ? const Text('1.0000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                              : Text(val.toStringAsFixed(4), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
