import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../components/absensi_card.dart';
import '../components/primary_button.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/theme_controller.dart';
import 'attendance_detail_map_page.dart';
import 'google_maps_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AttendanceProvider>();
      provider.fetchHistory();
      provider.fetchTodayAbsen();
      provider.fetchStats();
    });
  }

  Future<void> _submitAttendance(BuildContext context, bool isCheckIn) async {
    final provider = context.read<AttendanceProvider>();
    try {
      final message = await provider.submitAttendance(isCheckIn: isCheckIn);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message ??
                (isCheckIn
                    ? 'Absen masuk berhasil.'
                    : 'Absen pulang berhasil.'),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _openMap() {
    final provider = context.read<AttendanceProvider>();
    final today = provider.todayRecord;
    final lat = today?.displayLatitude ?? provider.lastPosition?.latitude;
    final lng = today?.displayLongitude ?? provider.lastPosition?.longitude;

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lokasi belum tersedia. Lakukan absensi terlebih dahulu.',
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceDetailMapPage(
          latitude: lat,
          longitude: lng,
          title: "Lokasi Absen",
        ),
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
    final authProvider = context.watch<AuthProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final user = authProvider.user;

    return Scaffold(
      body: attendanceProvider.isLoading && attendanceProvider.records.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  attendanceProvider.fetchHistory(),
                  attendanceProvider.fetchTodayAbsen(),
                  attendanceProvider.fetchStats(),
                  authProvider.fetchProfile(),
                ]);
              },
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(user?.name),
                  if (attendanceProvider.error != null &&
                      attendanceProvider.records.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildError(attendanceProvider.error!),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.all(18),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildTodayStatus(attendanceProvider),
                        const SizedBox(height: 18),
                        _buildActionButtons(attendanceProvider),
                        const SizedBox(height: 18),
                        _buildStats(attendanceProvider),
                        const SizedBox(height: 18),
                        _buildMenuGrid(),
                        const SizedBox(height: 120),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSliverAppBar(String? userName) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 8,
          20,
          32,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Colors.grey.shade900, Colors.grey.shade800]
                : [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedBuilder(
                animation: ThemeController.instance,
                builder: (context, _) {
                  final isDark = ThemeController.instance.isDarkMode;
                  return IconButton(
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.white,
                    ),
                    tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
                    onPressed: () =>
                        ThemeController.instance.toggleTheme(!isDark),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_greeting()},',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              userName ?? 'Peserta PPKD',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              readableDate(DateTime.now()),
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 54, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Coba Lagi',
            icon: Icons.refresh_rounded,
            onPressed: () => context.read<AttendanceProvider>().fetchHistory(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatus(AttendanceProvider provider) {
    final today = provider.todayRecord;
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
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStatus(
                  Icons.logout_rounded,
                  'Pulang',
                  pulang,
                  AppColors.warning,
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
        color: color.withValues(alpha: 0.10),
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

  Widget _buildActionButtons(AttendanceProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Masuk',
                icon: Icons.my_location_rounded,
                loading: provider.isCheckingIn,
                backgroundColor: AppColors.success,
                onPressed: () => _submitAttendance(context, true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: 'Pulang',
                icon: Icons.pin_drop_rounded,
                loading: provider.isCheckingOut,
                backgroundColor: AppColors.warning,
                onPressed: () => _submitAttendance(context, false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: 'Ajukan Izin / Sakit',
            icon: Icons.edit_document,
            backgroundColor: AppColors.primary,
            onPressed: () {
              Navigator.pushNamed(context, '/izin');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStats(AttendanceProvider provider) {
    return AbsensiCard(
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              'Total',
              provider.totalAbsen.toString(),
              Icons.calendar_month_rounded,
            ),
          ),
          Expanded(
            child: _statItem(
              'Masuk',
              provider.totalMasuk.toString(),
              Icons.verified_rounded,
            ),
          ),
          Expanded(
            child: _statItem(
              'Izin',
              provider.totalIzin.toString(),
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
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
          Icons.map_rounded,
          'Peta Lokasi',
          'Detail koordinat',
          _openMap,
        ),
        _menuCard(Icons.explore_rounded, 'Cari Lokasi', 'Posisi saat ini', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GoogleMapsScreenDay36()),
          );
        }),
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
          Icon(icon, color: AppColors.primary, size: 32),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
