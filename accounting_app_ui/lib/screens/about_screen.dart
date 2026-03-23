import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkımızda'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.info_outline, size: 80, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Muhasebe Sistemi Hakkında',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Bu uygulama, küçük ve orta ölçekli işletmelerin finansal işlemlerini (gelir, gider, fatura, personel takibi vb.) '
              'kolayca yönetebilmesi için geliştirilmiş modern bir muhasebe çözümüdür.',
              style: TextStyle(fontSize: 16, height: 1.5, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            Text(
              'Özellikler:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(Icons.check_circle, 'Gelişmiş Fatura Yönetimi (Alış/Satış, Proforma)'),
            _buildFeatureItem(Icons.check_circle, 'Cari Hesap ve İş Ortağı Takibi'),
            _buildFeatureItem(Icons.check_circle, 'Personel ve Bordro İşlemleri'),
            _buildFeatureItem(Icons.check_circle, 'Canlı Döviz Kurları (TCMB Entegre)'),
            _buildFeatureItem(Icons.check_circle, 'Kâr/Zarar, KDV ve Yaşlandırma Raporları'),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Sürüm 1.0.0\n© 2026 Tüm Hakları Saklıdır.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
