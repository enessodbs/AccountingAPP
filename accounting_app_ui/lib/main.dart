import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';
import 'services/theme_service.dart';
import 'services/locale_service.dart';
import 'l10n/app_localizations.dart';

final themeService = ThemeService();
final localeService = LocaleService();

void main() {
  runApp(AccountingApp(themeService: themeService, localeService: localeService));
}

class AccountingApp extends StatelessWidget {
  final ThemeService themeService;
  final LocaleService localeService;

  const AccountingApp({super.key, required this.themeService, required this.localeService});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([themeService, localeService]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Muhasebe Uygulaması',
          debugShowCheckedModeBanner: false,
          // Localization support
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr'),
            Locale('en'),
          ],
          locale: localeService.locale,
          themeMode: themeService.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF3F4F6),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              secondary: Color(0xFF10B981),
              surface: Color(0xFFFFFFFF),
              // ignore: deprecated_member_use
              background: Color(0xFFF3F4F6),
              error: Color(0xFFEF4444),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Color(0xFF1F2937),
              onError: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFFFFFFFF),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF111827),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3B82F6),
              secondary: Color(0xFF10B981),
              surface: Color(0xFF1F2937),
              // ignore: deprecated_member_use
              background: Color(0xFF111827),
              error: Color(0xFFEF4444),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Color(0xFFF9FAFB),
              onError: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F2937),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1F2937),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}
