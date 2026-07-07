import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const _key = 'app_language';
  String _language = 'Indonesia';
  Locale _locale = const Locale('id');

  String get language => _language;
  Locale get locale => _locale;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_key) ?? 'Indonesia';
    _locale = _language == 'English' ? const Locale('en') : const Locale('id');
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    _locale = value == 'English' ? const Locale('en') : const Locale('id');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
    notifyListeners();
  }
}
