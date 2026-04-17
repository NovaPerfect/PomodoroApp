import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  Locale _locale = const Locale('en');
  static const String _keyLocale = 'selected_locale';

  static const _supported = ['en', 'ru'];

  Locale get locale => _locale;

  Future<void> init() async {
    // Login screen always shows system language
    final systemCode = PlatformDispatcher.instance.locale.languageCode;
    _locale = _supported.contains(systemCode)
        ? Locale(systemCode)
        : const Locale('en');
    notifyListeners();
  }

  /// Call after login — restores user's saved language preference.
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyLocale);
    if (saved != null && _locale.languageCode != saved) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  /// Call on logout — resets to system language so login screen is correct.
  void resetToSystemLocale() {
    final systemCode = PlatformDispatcher.instance.locale.languageCode;
    final next = _supported.contains(systemCode)
        ? Locale(systemCode)
        : const Locale('en');
    if (_locale != next) {
      _locale = next;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
    notifyListeners();
  }
}
