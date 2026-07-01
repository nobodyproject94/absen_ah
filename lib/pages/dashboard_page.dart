import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/dio_client.dart';
import '../services/token_services.dart';
import '../models/attendance_record.dart';
import '../utils/absensi_ui.dart';
import '../utils/theme_controller.dart';
import 'attendance_detail_map_page.dart';
import 'attendance_history_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  UserModel? _user;
  List<AttendanceRecord> _records = [];
  bool _loading = true;
  bool _postingCheckIn = false;
  bool _postingCheckOut = false;
  String? _error;
  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Dio get _dio => createDioClient();

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = _dio;
      final apiService = ApiService(dio);
      final profileFuture = apiService.getProfile();
      final historyFuture = dio.get('/api/absen/history');

      final profileResponse = await profileFuture;
      final historyResponse = await historyFuture;

      final records = _parseAttendanceList(historyResponse.data);
      if (!mounted) return;
      setState(() {
        _user = profileResponse.data ?? profileResponse.user;
        _records = records;
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
    if (payload is Map) {
      raw =
          payload['data'] ??
          payload['absen'] ??
          payload['history'] ??
          payload['data_absen'];
    }
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (item) =>
                AttendanceRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }
    return [];
  }

  AttendanceRecord? get _todayRecord {
    final now = DateTime.now();
    final todayKey = '${now.year}-${dd(now.month)}-${dd(now.day)}';
    for (final r in _records) {
      final date = r.date ?? '';
      if (date.contains(todayKey) || date.contains('${now.day}')) return r;
    }
    return _records.isNotEmpty ? _records.first : null;
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'GPS belum aktif. Aktifkan layanan lokasi terlebih dahulu.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'Izin lokasi ditolak. Absensi membutuhkan latitude dan longitude.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengaktifkannya.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _submitAttendance({required bool checkIn}) async {
    setState(() {
      if (checkIn) {
        _postingCheckIn = true;
      } else {
        _postingCheckOut = true;
      }
    });

    try {
      final position = await _getCurrentPosition();
      _lastPosition = position;

      final body = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lat': position.latitude,
        'lng': position.longitude,
      };

      final endpoint = checkIn ? '/absen-check-in' : '/absen-check-out';
      final response = await _dio.post(endpoint, data: body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            extractApiMessage(
              response.data,
              checkIn ? 'Absen masuk berhasil.' : 'Absen pulang berhasil.',
            ),
          ),
        ),
      );
      await _loadDashboard();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            extractApiMessage(
              e.response?.data,
              'Absensi gagal. Periksa koneksi dan status absensi Anda.',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _postingCheckIn = false;
        _postingCheckOut = false;
      });
    }
  }

  Future<void> _logout() async {
    await TokenStorage.clearToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _openMap() {
    final today = _todayRecord;
    final lat = today?.displayLatitude ?? _lastPosition?.latitude;
    final lng = today?.displayLongitude ?? _lastPosition?.longitude;
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lokasi belum tersedia. Lakukan absensi atau buka riwayat yang memiliki koordinat.',
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceDetailMapPage(latitude: lat, longitude: lng),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 230,
                    pinned: true,
                    actions: [
                      AnimatedBuilder(
                        animation: ThemeController.instance,
                        builder: (context, _) => Switch(
                          value: ThemeController.instance.isDarkMode,
                          onChanged: ThemeController.instance.toggleTheme,
                        ),
                      ),
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: Theme.of(context).brightness == Brightness.dark
                                ? [Colors.grey.shade900, Colors.grey.shade800]
                                : [AbsensiColors.primary, AbsensiColors.secondary],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${_greeting()},',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _user?.name ?? 'Peserta PPKD',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              readableDate(DateTime.now()),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(18),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildTodayStatus(),
                        const SizedBox(height: 18),
                        _buildActionButtons(),
                        const SizedBox(height: 18),
                        _buildStats(),
                        const SizedBox(height: 18),
                        _buildMenuGrid(),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 54,
              color: AbsensiColors.danger,
            ),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Coba Lagi',
              icon: Icons.refresh_rounded,
              onPressed: _loadDashboard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStatus() {
    final today = _todayRecord;
    final masuk = today?.checkInTime ?? '-';
    final pulang = today?.checkOutTime ?? '-';
    return AbsensiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Absensi Hari Ini',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniStatus(
                  Icons.login_rounded,
                  'Masuk',
                  masuk,
                  AbsensiColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStatus(
                  Icons.logout_rounded,
                  'Pulang',
                  pulang,
                  AbsensiColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStatus(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            label: 'Absen Masuk',
            icon: Icons.my_location_rounded,
            loading: _postingCheckIn,
            backgroundColor: AbsensiColors.success,
            onPressed: () => _submitAttendance(checkIn: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            label: 'Absen Pulang',
            icon: Icons.pin_drop_rounded,
            loading: _postingCheckOut,
            backgroundColor: AbsensiColors.warning,
            onPressed: () => _submitAttendance(checkIn: false),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final total = _records.length;
    final complete = _records
        .where((r) => r.hasCheckedIn && r.hasCheckedOut)
        .length;
    final incomplete = total - complete;
    return AbsensiCard(
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              'Total',
              total.toString(),
              Icons.calendar_month_rounded,
            ),
          ),
          Expanded(
            child: _statItem(
              'Lengkap',
              complete.toString(),
              Icons.verified_rounded,
            ),
          ),
          Expanded(
            child: _statItem(
              'Belum',
              incomplete.toString(),
              Icons.pending_actions_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AbsensiColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.25,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _menuCard(
          Icons.history_rounded,
          'Riwayat',
          'Lihat data absensi',
          () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttendanceHistoryPage()),
            );
            _loadDashboard();
          },
        ),
        _menuCard(
          Icons.map_rounded,
          'Peta Lokasi',
          'Detail koordinat',
          _openMap,
        ),
        _menuCard(Icons.person_rounded, 'Profil', 'Data pengguna', () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
          _loadDashboard();
        }),
        _menuCard(
          Icons.refresh_rounded,
          'Refresh',
          'Sinkron API',
          _loadDashboard,
        ),
      ],
    );
  }

  Widget _menuCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return AbsensiCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AbsensiColors.primary, size: 32),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
