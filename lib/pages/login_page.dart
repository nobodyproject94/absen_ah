import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/dio_client.dart';
import '../services/token_services.dart';
import '../utils/absensi_ui.dart';
import 'main_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _requiredEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text))
      return 'Format email tidak valid';
    return null;
  }

  String? _requiredPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password tidak boleh kosong';
    if (text.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService(createDioClient());
      final body = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      };

      final response = await apiService.login(body);
      log('Login response: $response');
      final token = response.data?.token;

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak diterima dari server.');
      }

      await TokenStorage.saveToken(token);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
        (_) => false,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_dioErrorMessage(e))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal login: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _dioErrorMessage(DioException e) {
    if (e.response == null) return 'Gagal login: Terjadi kesalahan jaringan.';
    final status = e.response!.statusCode;
    if (status == 401 || status == 404)
      return 'Gagal login: email atau password salah.';
    if (status == 422)
      return 'Gagal login: ${extractApiMessage(e.response?.data, 'Data login tidak valid.')}';
    if (status == 500) return 'Gagal login: server sedang bermasalah (500).';
    return 'Gagal login: ${extractApiMessage(e.response?.data, e.message ?? 'Terjadi kesalahan.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [AbsensiColors.primary, AbsensiColors.secondary],
                  ),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: 46,
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'ABSENSI PPKD',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk untuk mencatat kehadiran secara real-time berbasis lokasi.',
              ),
              const SizedBox(height: 28),
              AbsensiCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: absensiInputDecoration(
                          'Email',
                          Icons.email_rounded,
                        ),
                        validator: _requiredEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        decoration:
                            absensiInputDecoration(
                              'Password',
                              Icons.lock_rounded,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                        validator: _requiredPassword,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Login',
                        icon: Icons.login_rounded,
                        loading: _isLoading,
                        onPressed: _login,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterPage(),
                                ),
                              ),
                        child: const Text('Belum punya akun? Register di sini'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
