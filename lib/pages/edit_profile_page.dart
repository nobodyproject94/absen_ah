import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/dio_client.dart';
import '../models/training_model.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _batchIdController;
  late String _jenisKelamin;

  bool _isLoading = false;
  String? _base64Image;
  File? _imageFile;

  List<TrainingModel>? _trainings;
  bool _isLoadingTrainings = true;
  int? _selectedTrainingId;

  // Theme colors disamakan dengan screen Profile Dashboard pada screenshot
  static const Color _pageBg = Color(0xFFFFF7FF);
  static const Color _cardBg = Color(0xFFFDF6FF);
  static const Color _primaryPurple = Color(0xFF76558F);
  static const Color _iconBlueGrey = Color(0xFF6D8791);
  static const Color _labelGrey = Color(0xFFB5ADB8);
  static const Color _dividerColor = Color(0xFFD8CCD9);
  static const Color _textDark = Color(0xFF2B2530);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _imageFile = File(pickedFile.path);
        _base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
      });
    }
  }

  Future<void> _fetchTrainings() async {
    try {
      final dio = createDioClient();
      final apiService = ApiService(dio);
      final response = await apiService.getTrainings();
      if (!mounted) return;
      setState(() {
        _trainings = response.data;
        _isLoadingTrainings = false;

        if (_trainings != null && _selectedTrainingId != null) {
          final exists = _trainings!.any((t) => t.id == _selectedTrainingId);
          if (!exists) _selectedTrainingId = null;
        }
      });
    } catch (e) {
      debugPrint('Gagal mengambil data training: $e');
      if (!mounted) return;
      setState(() => _isLoadingTrainings = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _passwordController = TextEditingController();
    _batchIdController = TextEditingController(
      text: widget.user.batchId?.toString() ?? '',
    );
    _selectedTrainingId = widget.user.trainingId;
    _jenisKelamin =
        (widget.user.jenisKelamin == 'L' || widget.user.jenisKelamin == 'P')
        ? widget.user.jenisKelamin!
        : 'L';
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

  void _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final dio = createDioClient();
      final apiService = ApiService(dio);

      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'jenis_kelamin': _jenisKelamin,
      };

      if (_batchIdController.text.trim().isNotEmpty) {
        body['batch_id'] = int.tryParse(_batchIdController.text.trim());
      }

      if (_selectedTrainingId != null) {
        body['training_id'] = _selectedTrainingId;
      }

      if (_passwordController.text.trim().isNotEmpty) {
        body['password'] = _passwordController.text.trim();
      }

      debugPrint('--> Update profile body: $body');
      final response = await apiService.updateProfile(body);
      debugPrint(
        '<-- Update profile response: ${response.message} | '
        'user=${response.data?.name ?? response.user?.name}',
      );

      String? newProfilePhoto = widget.user.profilePhoto;

      if (_base64Image != null) {
        final photoBody = <String, dynamic>{'profile_photo': _base64Image!};
        final photoResponse = await apiService.updateProfilePhoto(photoBody);
        debugPrint('<-- Update photo response: ${photoResponse.message}');

        final returnedPhoto =
            photoResponse.data?.profilePhoto ??
            photoResponse.user?.profilePhoto;
        if (returnedPhoto != null) newProfilePhoto = returnedPhoto;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile berhasil diupdate!')),
      );

      // Kembalikan 'true' agar ProfilePage melakukan fetch ulang ke server,
      // sehingga data yang ditampilkan 100% konsisten dengan database.
      Navigator.pop(context, true);
    } on DioException catch (e) {
      debugPrint(
        'XXX Update profile error: ${e.response?.statusCode} ${e.response?.data}',
      );
      String errorMessage = 'Gagal update profile: Terjadi kesalahan jaringan.';
      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          final errors = e.response?.data['errors'];
          final msg = e.response?.data['message'];
          errorMessage = errors != null
              ? 'Gagal update profile (422): $errors'
              : 'Gagal update profile (422): ${msg ?? 'Data tidak valid'}';
        } else if (e.response!.statusCode == 401) {
          errorMessage =
              'Gagal update profile: Sesi habis, silakan login ulang.';
        } else if (e.response!.statusCode == 500) {
          errorMessage =
              'Gagal update profile: Terjadi kesalahan pada server (500).';
        } else {
          errorMessage =
              'Gagal update profile (${e.response!.statusCode}): ${e.response?.data['message'] ?? e.message}';
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e, st) {
      debugPrint('XXX Update profile exception: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update profile: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) return 'Email tidak boleh kosong';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(val.trim())) return 'Format email tidak valid';
    return null;
  }

  String _photoUrl(String value) {
    return value.startsWith('http')
        ? value
        : 'https://appabsensi.mobileprojp.com/storage/$value';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2196F3),
                            Color(0xFF00BCD4),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildAvatar(),
                          const SizedBox(height: 12),
                          const Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildFormCard(),
                            const SizedBox(height: 26),
                            _buildSaveButton(),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Container(
              width: 76,
              height: 76,
              color: Colors.transparent,
              child: _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                  : (widget.user.profilePhoto != null &&
                            widget.user.profilePhoto!.isNotEmpty
                        ? Image.network(
                            _photoUrl(widget.user.profilePhoto!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(
                                '[ProfilePhoto] Gagal memuat gambar: $error',
                              );
                              return const Icon(
                                Icons.person,
                                size: 46,
                                color: _textDark,
                              );
                            },
                          )
                        : const Icon(Icons.person, size: 46, color: _textDark)),
            ),
          ),
          Positioned(
            right: -8,
            bottom: -2,
            child: InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _cardBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 17,
                  color: _primaryPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        children: [
          _profileField(
            icon: Icons.person,
            child: TextFormField(
              controller: _nameController,
              style: const TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              decoration: const InputDecoration(labelText: 'Nama'),
              validator: (val) => val == null || val.trim().isEmpty
                  ? 'Nama tidak boleh kosong'
                  : null,
            ),
          ),
          _divider(),
          _profileField(
            icon: Icons.email,
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              decoration: const InputDecoration(labelText: 'Email'),
              validator: _validateEmail,
            ),
          ),
          _divider(),
          _profileField(
            icon: Icons.lock,
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Kosongkan jika tidak diubah',
                hintStyle: TextStyle(
                  color: _labelGrey,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          _divider(),
          _profileField(
            icon: Icons.transgender,
            child: DropdownButtonFormField<String>(
              initialValue: _jenisKelamin,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
              dropdownColor: _cardBg,
              iconEnabledColor: _primaryPurple,
              style: const TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              items: const [
                DropdownMenuItem(value: 'L', child: Text('L')),
                DropdownMenuItem(value: 'P', child: Text('P')),
              ],
              onChanged: (val) => setState(() => _jenisKelamin = val ?? 'L'),
            ),
          ),
          _divider(),
          _profileField(
            icon: Icons.badge,
            child: TextFormField(
              controller: _batchIdController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              decoration: const InputDecoration(labelText: 'Batch ID'),
            ),
          ),
          _divider(),
          _profileField(
            icon: Icons.school,
            child: _isLoadingTrainings
                ? const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(minHeight: 2),
                  )
                : DropdownButtonFormField<int>(
                    initialValue: _selectedTrainingId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Training'),
                    dropdownColor: _cardBg,
                    iconEnabledColor: _primaryPurple,
                    style: const TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    items:
                        _trainings
                            ?.map(
                              (t) => DropdownMenuItem<int>(
                                value: t.id,
                                child: Text(t.title ?? '-'),
                              ),
                            )
                            .toList() ??
                        [],
                    onChanged: (val) =>
                        setState(() => _selectedTrainingId = val),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _profileField({required IconData icon, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 34,
            child: Icon(icon, color: _iconBlueGrey, size: 22),
          ),
          const SizedBox(width: 4),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 18,
      thickness: 1,
      color: _dividerColor,
      indent: 36,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _updateProfile,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save, size: 18, color: Colors.white),
        label: Text(
          _isLoading ? 'Saving...' : 'Save Changes',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }
}
