import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../providers/attendance_provider.dart';
import '../services/dio_client.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/error_translator.dart';
import '../l10n/app_localizations.dart';
import '../components/absensi_card.dart';
import '../components/primary_button.dart';
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
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  String _dd(int value) => value.toString().padLeft(2, '0');

  Future<void> _fetchHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final queryParams = <String, dynamic>{};
      if (_selectedDateRange != null) {
        queryParams['start'] = '${_selectedDateRange!.start.year}-${_dd(_selectedDateRange!.start.month)}-${_dd(_selectedDateRange!.start.day)}';
        queryParams['end'] = '${_selectedDateRange!.end.year}-${_dd(_selectedDateRange!.end.month)}-${_dd(_selectedDateRange!.end.day)}';
      }

      final response = await createDioClient().get('/api/absen/history', queryParameters: queryParams);
      if (!mounted) return;
      setState(() {
        _records = AttendanceProvider.parseAttendanceList(response.data);
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

  Future<void> _selectDateRange() async {
    final initialRange = _selectedDateRange ?? DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      confirmText: 'PILIH',
      saveText: 'SIMPAN',
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _fetchHistory();
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedDateRange = null;
    });
    _fetchHistory();
  }

  Future<void> _deleteAttendance(AttendanceRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    if (record.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errIdNotFound)),
      );
      return;
    }

    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDialogTitle),
        content: Text(l10n.deleteDialogContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancelButton)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );

    if (approved != true) return;

    try {
      final response = await createDioClient().delete('/api/absen/${record.id}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(extractApiMessage(response.data, l10n.deleteSuccess)),
          backgroundColor: AppColors.success,
        ),
      );
      await _fetchHistory();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(extractApiMessage(e.response?.data, l10n.errDeleteFailed)),
          backgroundColor: AppColors.danger,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorTranslator.translate(context, e)),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _openMap(AttendanceRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    final lat = record.displayLatitude;
    final lng = record.displayLongitude;
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errCoordsNotAvailable)),
      );
      return;
    }
    final updated = await Navigator.push<AttendanceRecord>(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceDetailMapPage(
          latitude: lat,
          longitude: lng,
          title: 'Lokasi ${record.date ?? 'Absensi'}',
          record: record,
        ),
      ),
    );
    if (updated != null && mounted) {
      final index = _records.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        setState(() {
          _records[index] = updated;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final l10n = AppLocalizations.of(context)!;
    
    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text(l10n.historyTitle),
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.date_range_rounded),
                onPressed: _selectDateRange,
              ),
            ],
          ),
          if (_selectedDateRange != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.filter_alt_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Filter: ${readableDate(_selectedDateRange!.start)} - ${readableDate(_selectedDateRange!.end)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _clearFilter,
                          child: const Icon(Icons.cancel_rounded, color: AppColors.primary, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_error != null)
            SliverFillRemaining(child: _errorView())
          else if (_records.isEmpty)
            SliverFillRemaining(child: _emptyView())
          else
            _sliverListView(),
        ],
      ),
    );
  }

  Widget _errorView() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 54, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(ErrorTranslator.translate(context, _error!), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PrimaryButton(label: l10n.tryAgainButton, icon: Icons.refresh_rounded, onPressed: _fetchHistory),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(l10n.emptyHistory, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _sliverListView() {
    final l10n = AppLocalizations.of(context)!;
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final record = _records[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AbsensiCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            record.date ?? l10n.dateNotAvailable,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        _statusChip(record),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'map') _openMap(record);
                            if (value == 'delete') _deleteAttendance(record);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'map', child: Text(l10n.viewMapMenu)),
                            PopupMenuItem(value: 'delete', child: Text(l10n.deleteAttendanceMenu)),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (record.isIzin) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.permitReasonLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(record.alasanIzin ?? '-', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(child: _timeBox(l10n.checkInLabel, record.checkInTime ?? '-', Icons.login_rounded)),
                          const SizedBox(width: 10),
                          Expanded(child: _timeBox(l10n.checkOutLabel, record.checkOutTime ?? '-', Icons.logout_rounded)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.place_rounded, size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              record.displayAddress,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          childCount: _records.length,
        ),
      ),
    );
  }

  Widget _statusChip(AttendanceRecord record) {
    final l10n = AppLocalizations.of(context)!;
    final isIzin = record.isIzin;
    final isLate = record.isLate == true;
    final isAnomaly = record.timeAnomaly == true;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAnomaly) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(l10n.timeAnomalyBadge, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          const SizedBox(width: 4),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isIzin
                ? AppColors.warning.withValues(alpha: 0.15)
                : (isLate ? AppColors.danger.withValues(alpha: 0.15) : AppColors.success.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isIzin ? l10n.statPermit : (isLate ? l10n.statusLate.replaceAll('• ', '') : l10n.statPresent),
            style: TextStyle(
              color: isIzin ? AppColors.warning : (isLate ? AppColors.danger : AppColors.success),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeBox(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primary.withValues(alpha: .08),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
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
