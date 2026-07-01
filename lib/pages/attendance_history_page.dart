import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../services/dio_client.dart';
import '../utils/absensi_ui.dart';
import 'attendance_detail_map_page.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  bool _loading = true;
  String? _error;
  List<AttendanceRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await createDioClient().get('/api/absen/history');
      if (!mounted) return;
      setState(() {
        _records = _parseAttendanceList(response.data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<AttendanceRecord> _parseAttendanceList(dynamic payload) {
    dynamic raw = payload;
    if (payload is Map) raw = payload['data'] ?? payload['absen'] ?? payload['history'] ?? payload['data_absen'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => AttendanceRecord.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  Future<void> _deleteAttendance(AttendanceRecord record) async {
    if (record.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID absen tidak ditemukan.')));
      return;
    }

    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Absen?'),
        content: const Text('Data absensi ini akan dihapus dari server. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (approved != true) return;

    try {
      final response = await createDioClient().delete('/delete-absen', queryParameters: {'id': record.id});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractApiMessage(response.data, 'Data absen berhasil dihapus.'))),
      );
      await _fetchHistory();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractApiMessage(e.response?.data, 'Gagal menghapus data absen.'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus data absen: $e')));
    }
  }

  void _openMap(AttendanceRecord record) {
    final lat = record.displayLatitude;
    final lng = record.displayLongitude;
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Koordinat lokasi tidak tersedia.')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceDetailMapPage(latitude: lat, longitude: lng, title: 'Lokasi ${record.date ?? 'Absensi'}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: _fetchHistory,
                  child: _records.isEmpty ? _emptyView() : _listView(),
                ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 54, color: AbsensiColors.danger),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Coba Lagi', icon: Icons.refresh_rounded, onPressed: _fetchHistory),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 120),
        Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text('Belum ada riwayat absensi.', textAlign: TextAlign.center),
      ],
    );
  }

  Widget _listView() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _records.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = _records[index];
        return AbsensiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: AbsensiColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      record.date ?? 'Tanggal tidak tersedia',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'map') _openMap(record);
                      if (value == 'delete') _deleteAttendance(record);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'map', child: Text('Lihat Map')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus Absen')),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(child: _timeBox('Masuk', record.checkInTime ?? '-', Icons.login_rounded)),
                  const SizedBox(width: 10),
                  Expanded(child: _timeBox('Pulang', record.checkOutTime ?? '-', Icons.logout_rounded)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.place_rounded, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      record.displayLatitude == null || record.displayLongitude == null
                          ? 'Lokasi tidak tersedia'
                          : '${record.displayLatitude}, ${record.displayLongitude}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timeBox(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AbsensiColors.primary.withOpacity(.08),
      ),
      child: Row(
        children: [
          Icon(icon, color: AbsensiColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
