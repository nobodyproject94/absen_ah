import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  static const _key = 'app_notifications_enabled';
  bool _isNotifEnabled = true;

  bool get isNotifEnabled => _isNotifEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isNotifEnabled = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> toggleNotification(bool value) async {
    _isNotifEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    notifyListeners();
  }
}
