import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'preferred_locale';
  Locale _locale = const Locale('tr');

  Locale get locale => _locale;
  bool get isTurkish => _locale.languageCode == 'tr';

  LocaleService() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    if (saved == 'en') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('tr');
    }
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    _locale = _locale.languageCode == 'tr' ? const Locale('en') : const Locale('tr');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, _locale.languageCode);
    notifyListeners();
  }

  Future<void> setLocale(String langCode) async {
    _locale = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, langCode);
    notifyListeners();
  }
}
