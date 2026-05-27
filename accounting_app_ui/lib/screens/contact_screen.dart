import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('İletişim'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.contact_support_outlined, size: 80, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Bizimle İletişime Geçin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'Uygulama hakkında sorularınız, destek talepleriniz veya önerileriniz için aşağıdaki kanallardan bize ulaşabilirsiniz.',
              style: TextStyle(fontSize: 16, height: 1.5, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 32),
            
            _buildContactItem(
              context,
              icon: Icons.location_on,
              title: 'Adres',
              subtitle: 'Teknoloji Vadisi, Bilişim Plaza Kat: 4 No: 12, İstanbul / Türkiye',
            ),
            const Divider(height: 32),
            
            _buildContactItem(
              context,
              icon: Icons.phone,
              title: 'Telefon',
              subtitle: '+90 (850) 123 45 67',
            ),
            const Divider(height: 32),
            
            _buildContactItem(
              context,
              icon: Icons.email,
              title: 'E-Posta',
              subtitle: 'destek@muhasebesistemi.com',
            ),
            const Divider(height: 32),
            
            _buildContactItem(
              context,
              icon: Icons.language,
              title: 'Web Sitesi',
              subtitle: 'www.muhasebesistemi.com',
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'destek@muhasebesistemi.com',
                    query: encodeQueryParameters(<String, String>{
                      'subject': 'Muhasebe Sistemi Destek Talebi',
                    }),
                  );

                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  } else {
                    if (context.mounted) {
                      CustomToast.showError(context, 'E-posta istemcisi açılamadı. Lütfen destek@muhasebesistemi.com adresine yazın.');
                    }
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('Bize Yazın'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
