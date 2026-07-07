import 'dart:async';
import 'package:flutter/material.dart';
import '../services/time_service.dart';

class TimeProvider extends ChangeNotifier {
  int _clientOffsetMs = 0;
  bool _isSyncing = false;
  String _syncSource = 'Belum Disinkronkan';
  DateTime? _lastSyncTime;

  int get clientOffsetMs => _clientOffsetMs;
  bool get isSyncing => _isSyncing;
  String get syncSource => _syncSource;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Waktu server saat ini yang dihitung secara dinamis dari jam lokal + offset
  DateTime get currentTime => DateTime.now().add(Duration(milliseconds: _clientOffsetMs));

  TimeProvider() {
    syncTime();
    // Secara otomatis sinkron ulang setiap 30 menit
    Timer.periodic(const Duration(minutes: 30), (_) => syncTime());
  }

  Future<void> syncTime() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    try {
      final result = await TimeService.fetchServerTime();
      _clientOffsetMs = result.clientOffsetMs;
      _syncSource = result.source;
      _lastSyncTime = DateTime.now();
      debugPrint('Time synced via $_syncSource: offset = ${_clientOffsetMs}ms');
    } catch (e) {
      debugPrint('Time sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
