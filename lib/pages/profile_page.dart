import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import '../models/user_model.dart';
import '../models/training_model.dart';
import '../models/training_response.dart';
import '../services/api_service.dart';
import '../services/dio_client.dart';
import '../services/token_services.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';
import '../utils/absensi_ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;
  List<TrainingModel>? _trainings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final dio = createDioClient();
      final apiService = ApiService(dio);
      // Token disisipkan otomatis oleh interceptor di dio_client.dart

      final profileFuture = apiService.getProfile();
      TrainingResponse? trainingsResponse;
      try {
        trainingsResponse = await apiService.getTrainings();
      } catch (_) {
        trainingsResponse = null;
      }

      final response = await profileFuture;

      setState(() {
        _user = response.data ?? response.user;
        _trainings = trainingsResponse?.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await TokenStorage.clearToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _refreshProfile({bool showLoading = true}) {
    _fetchProfile(showLoading: showLoading);
  }

  String _getTrainingTitle(int? id) {
    if (id == null) return "-";
    if (_trainings == null) return id.toString();
    try {
      final t = _trainings!.firstWhere((t) => t.id == id);
      return t.title ?? id.toString();
    } catch (e) {
      return id.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Error: $_error"))
          : _user == null
          ? const Center(child: Text("Data profil tidak ditemukan"))
          : RefreshIndicator(
              onRefresh: () async => _refreshProfile(showLoading: false),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: _logout,
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: Theme.of(context).brightness == Brightness.dark
                                ? [Colors.grey.shade900, Colors.grey.shade800]
                                : [AbsensiColors.primary, AbsensiColors.secondary],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child:
                                    _user!.profilePhoto != null &&
                                        _user!.profilePhoto!.isNotEmpty
                                    ? Image.network(
                                        _user!.profilePhoto!.startsWith('http')
                                            ? _user!.profilePhoto!
                                            : 'https://appabsensi.mobileprojp.com/storage/${_user!.profilePhoto}',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                      )
                                    : Container(
                                        color: Colors.white,
                                        child: const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _user!.name ?? "Peserta PPKD",
                              style: const TextStyle(
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
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Theme.of(context).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProfileItem(
                                  Icons.person,
                                  "Nama",
                                  _user!.name ?? "-",
                                ),
                                const Divider(height: 24),
                                _buildProfileItem(
                                  Icons.email,
                                  "Email",
                                  _user!.email ?? "-",
                                ),
                                const Divider(height: 24),
                                _buildProfileItem(
                                  Icons.transgender,
                                  "Jenis Kelamin",
                                  _user!.jenisKelamin == 'L'
                                      ? 'Laki-laki'
                                      : (_user!.jenisKelamin == 'P'
                                            ? 'Perempuan'
                                            : '-'),
                                ),
                                const Divider(height: 24),
                                _buildProfileItem(
                                  Icons.badge,
                                  "Batch ID",
                                  _user!.batchId?.toString() ?? "-",
                                ),
                                const Divider(height: 24),
                                _buildProfileItem(
                                  Icons.school,
                                  "Training",
                                  _getTrainingTitle(_user!.trainingId),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfilePage(user: _user!),
                              ),
                            );
                            if (result != null && result is UserModel) {
                              setState(() {
                                _user = result;
                              });
                            } else if (result == true) {
                              _refreshProfile();
                            }
                          },
                        ),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
          ),
    );
  }



  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2196F3), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
