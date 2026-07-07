import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../components/absensi_card.dart';
import '../components/live_clock_widget.dart';
import '../components/primary_button.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/theme_controller.dart';
import '../utils/error_translator.dart';
import '../l10n/app_localizations.dart';
import 'attendance_submit_map_page.dart';

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

  String _greeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 11) return l10n.greetingMorning;
    if (hour < 15) return l10n.greetingAfternoon;
    if (hour < 18) return l10n.greetingEvening;
    return l10n.greetingNight;
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
                        const LiveClockWidget(),
                        const SizedBox(height: 18),
                        _buildTodayStatus(attendanceProvider),
                        const SizedBox(height: 18),
                        _buildActionButtons(attendanceProvider),
                        const SizedBox(height: 18),
                        _buildStats(attendanceProvider),
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
    final l10n = AppLocalizations.of(context)!;
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
                    tooltip: isDark ? l10n.lightModeTooltip : l10n.darkModeTooltip,
                    onPressed: () =>
                        ThemeController.instance.toggleTheme(!isDark),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_greeting(context)},',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              userName ?? l10n.defaultUser,
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 54, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(ErrorTranslator.translate(context, error), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          PrimaryButton(
            label: l10n.tryAgainButton,
            icon: Icons.refresh_rounded,
            onPressed: () => context.read<AttendanceProvider>().fetchHistory(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatus(AttendanceProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final today = provider.todayRecord;
    final masuk = today?.checkInTime ?? '-';
    final pulang = today?.checkOutTime ?? '-';
    final isLate = today?.isLate == true;
    final isAnomaly = today?.timeAnomaly == true;

    return AbsensiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.todayAttendance,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              if (today != null && today.hasCheckedIn)
                Row(
                  children: [
                    if (isAnomaly) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(l10n.timeAnomalyBadge, style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLate ? AppColors.danger.withValues(alpha: 0.15) : AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isLate ? l10n.statusLate : l10n.statusOnTime,
                        style: TextStyle(
                          color: isLate ? AppColors.danger : AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniStatus(
                  Icons.login_rounded,
                  l10n.checkInLabel,
                  masuk,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStatus(
                  Icons.logout_rounded,
                  l10n.checkOutLabel,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: l10n.checkInLabel,
                icon: Icons.my_location_rounded,
                loading: provider.isCheckingIn,
                backgroundColor: AppColors.success,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttendanceSubmitMapPage(isCheckIn: true),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: l10n.checkOutLabel,
                icon: Icons.pin_drop_rounded,
                loading: provider.isCheckingOut,
                backgroundColor: AppColors.warning,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttendanceSubmitMapPage(isCheckIn: false),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: l10n.permitButton,
            icon: Icons.edit_document,
            onPressed: () {
              Navigator.pushNamed(context, '/izin');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStats(AttendanceProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    return AbsensiCard(
      child: Row(
        children: [
          Expanded(
            child: _statItem(
              l10n.statTotal,
              provider.totalAbsen.toString(),
              Icons.calendar_month_rounded,
            ),
          ),
          Expanded(
            child: _statItem(
              l10n.statPresent,
              provider.totalMasuk.toString(),
              Icons.verified_rounded,
            ),
          ),
          Expanded(
            child: _statItem(
              l10n.statPermit,
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
}
