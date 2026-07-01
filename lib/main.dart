import 'package:flutter/material.dart';
import 'package:absen_ah/pages/login_page.dart';
import 'package:absen_ah/pages/main_page.dart';
import 'package:absen_ah/services/token_services.dart';
import 'package:absen_ah/utils/theme_controller.dart';

void main() {
  runApp(const AbsensiApp());
}

class AbsensiApp extends StatefulWidget {
  const AbsensiApp({super.key});

  @override
  State<AbsensiApp> createState() => _AbsensiAppState();
}

class _AbsensiAppState extends State<AbsensiApp> {
  final ThemeController _themeController = ThemeController.instance;
  bool _initialized = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _themeController.loadTheme();
    _token = await TokenStorage.getToken();
    if (!mounted) return;
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Absensi PPKD',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F62FE),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: _themeController.themeMode,
          home: !_initialized
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : (_token != null && _token!.isNotEmpty
                    ? const MainPage()
                    : const LoginPage()),
        );
      },
    );
  }
}
