import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:absen_ah/pages/dashboard_page.dart';
import 'package:absen_ah/pages/attendance_history_page.dart';
import 'package:absen_ah/pages/profile_page.dart';
import 'package:absen_ah/utils/app_colors.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late final BottomBarController _bottomBarController;

  @override
  void initState() {
    super.initState();
    _bottomBarController = BottomBarController();
  }

  @override
  void dispose() {
    _bottomBarController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const DashboardPage(),
    const AttendanceHistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: BottomBar(
        controller: _bottomBarController,
        theme: BottomBarThemeData(
          barDecoration: BoxDecoration(color: Theme.of(context).cardColor),
        ),
        layout: BottomBarLayout(
          borderRadius: BorderRadius.circular(32),
          width: MediaQuery.of(context).size.width * 0.85,
        ),
        motion: const BottomBarMotion(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
        scrollBehavior: const BottomBarScrollBehavior(hideOnScroll: false),
        body: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.axis == Axis.horizontal) return false;

            if (notification.direction == ScrollDirection.reverse) {
              _bottomBarController.hide();
            } else if (notification.direction == ScrollDirection.forward) {
              _bottomBarController.show();
            }
            return false;
          },
          child: IndexedStack(index: _currentIndex, children: _pages),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomBarItem(0, Icons.home_rounded, 'Home'),
              _buildBottomBarItem(1, Icons.history_rounded, 'Riwayat'),
              _buildBottomBarItem(2, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : Colors.grey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
