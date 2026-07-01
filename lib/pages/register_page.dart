import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/training_model.dart';
import '../services/api_service.dart';
import '../services/dio_client.dart';
import '../services/token_services.dart';
import '../utils/absensi_ui.dart';
import 'login_page.dart';
import 'main_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _batchIdController = TextEditingController(text: '1');

  String _jenisKelamin = 'L';
  bool _isLoading = false;
  bool _loadingTrainings = true;
  bool _obscurePassword = true;
  List<TrainingModel> _trainings = [];
  int? _selectedTrainingId;

  @override
  void initState() {
    super.initState();
    _fetchTrainings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _batchIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrainings() async {
    try {
      final response = await ApiService(createDioClient()).getTrainings();
      final list = response.data ?? [];
      if (!mounted) return;
      setState(() {
        _trainings = list;
        _selectedTrainingId = list.isNotEmpty ? list.first.id : null;
        _loadingTrainings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingTrainings = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService(createDioClient());
      final body = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'jenis_kelamin': _jenisKelamin,
        'batch_id': int.tryParse(_batchIdController.text.trim()) ?? 1,
        'training_id': _selectedTrainingId ?? 1,
        'profile_photo':
            'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
      };

      final dynamic response = await apiService.register(body);
      final token = response?.data?.token?.toString();

      if (!mounted) return;
      if (token != null && token.isNotEmpty) {
        await TokenStorage.saveToken(token);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil. Silakan login.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_dioErrorMessage(e))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mendaftar: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _dioErrorMessage(DioException e) {
    if (e.response == null)
      return 'Gagal mendaftar: Terjadi kesalahan jaringan.';
    final status = e.response!.statusCode;
    if (status == 422)
      return 'Gagal mendaftar: ${extractApiMessage(e.response?.data, 'Data registrasi tidak valid.')}';
    if (status == 500)
      return 'Gagal mendaftar: server sedang bermasalah (500).';
    return 'Gagal mendaftar: ${extractApiMessage(e.response?.data, e.message ?? 'Terjadi kesalahan.')}';
  }

  String? _required(String? value, String label) {
    if ((value ?? '').trim().isEmpty) return '$label tidak boleh kosong';
    return null;
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text))
      return 'Format email tidak valid';
    return null;
  }

  String? _passwordValidator(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password tidak boleh kosong';
    if (text.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Akun Baru',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lengkapi data peserta untuk aktivasi akun absensi PPKD.',
              ),
              const SizedBox(height: 22),
              AbsensiCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: absensiInputDecoration(
                          'Nama',
                          Icons.person_rounded,
                        ),
                        validator: (v) => _required(v, 'Nama'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: absensiInputDecoration(
                          'Email',
                          Icons.email_rounded,
                        ),
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
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
                        validator: _passwordValidator,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _jenisKelamin,
                        isExpanded: true,
                        decoration: absensiInputDecoration(
                          'Jenis Kelamin',
                          Icons.transgender_rounded,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'L',
                            child: Text('Laki-laki'),
                          ),
                          DropdownMenuItem(
                            value: 'P',
                            child: Text('Perempuan'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _jenisKelamin = value ?? 'L'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _batchIdController,
                        keyboardType: TextInputType.number,
                        decoration: absensiInputDecoration(
                          'Batch ID',
                          Icons.badge_rounded,
                        ),
                        validator: (v) => _required(v, 'Batch ID'),
                      ),
                      const SizedBox(height: 14),
                      _loadingTrainings
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(),
                            )
                          : DropdownButtonFormField<int>(
                              initialValue: _selectedTrainingId,
                              isExpanded: true,
                              decoration: absensiInputDecoration(
                                'Training',
                                Icons.school_rounded,
                              ),
                              items: _trainings
                                  .map(
                                    (t) => DropdownMenuItem<int>(
                                      value: t.id,
                                      child: Text(
                                        t.title ?? 'Training ${t.id}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              validator: (v) =>
                                  v == null ? 'Training harus dipilih' : null,
                              onChanged: (value) =>
                                  setState(() => _selectedTrainingId = value),
                            ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Register',
                        icon: Icons.person_add_alt_1_rounded,
                        loading: _isLoading,
                        onPressed: _register,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              ),
                        child: const Text('Sudah punya akun? Login di sini'),
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
