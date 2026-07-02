import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absen_ah/pages/login_page.dart';
import 'package:absen_ah/pages/main_page.dart';
import 'package:absen_ah/pages/register_page.dart';
import 'package:absen_ah/pages/splash_page.dart';
import 'package:absen_ah/services/token_services.dart';
import 'package:absen_ah/utils/theme_controller.dart';
import 'package:absen_ah/providers/auth_provider.dart';
import 'package:absen_ah/providers/attendance_provider.dart';
import 'package:absen_ah/providers/language_provider.dart';
import 'package:absen_ah/providers/notification_settings_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadLanguage()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()..loadSettings()),
      ],
      child: const AbsensiApp(),
    ),
  );
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
    // Show splash for at least 2 seconds
    await Future.wait([
      _themeController.loadTheme(),
      Future.delayed(const Duration(seconds: 2)),
    ]);
    
    _token = await TokenStorage.getToken();
    
    if (!mounted) return;
    
    if (_token != null && _token!.isNotEmpty) {
      // Fetch profile initially if logged in
      context.read<AuthProvider>().fetchProfile();
    }
    
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
          navigatorKey: navigatorKey,
          title: 'Absensi PPKD',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F62FE)),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: _themeController.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => !_initialized
                ? const SplashPage()
                : (_token != null && _token!.isNotEmpty ? const MainPage() : const LoginPage()),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/main': (context) => const MainPage(),
          },
        );
      },
    );
  }
}
