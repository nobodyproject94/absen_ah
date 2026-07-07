import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/time_provider.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';

class LiveClockWidget extends StatefulWidget {
  const LiveClockWidget({super.key});

  @override
  State<LiveClockWidget> createState() => _LiveClockWidgetState();
}

class _LiveClockWidgetState extends State<LiveClockWidget> {
  Timer? _timer;
  late DateTime _displayTime;

  @override
  void initState() {
    super.initState();
    _displayTime = context.read<TimeProvider>().currentTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _displayTime = context.read<TimeProvider>().currentTime;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeProvider = context.watch<TimeProvider>();
    final timeStr = DateFormat('HH:mm:ss').format(_displayTime);
    final dateStr = readableDate(_displayTime);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: 10),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.primary.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: timeProvider.isSyncing ? AppColors.warning : AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeProvider.isSyncing
                        ? 'Menyinkronkan waktu...'
                        : '• Waktu Server (${timeProvider.syncSource})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ],
              ),
              InkWell(
                onTap: () => timeProvider.syncTime(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.sync_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      const Text(
                        'Sync',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
