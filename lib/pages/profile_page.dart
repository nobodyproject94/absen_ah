import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/notification_settings_provider.dart';
import '../utils/app_colors.dart';
import '../utils/theme_controller.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().fetchProfile();
    });
  }

  Future<void> _pickImage(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    // Bottom sheet for image source
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto (Kamera)'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        final base64Image = 'data:image/png;base64,${base64Encode(bytes)}';

        final success = await authProvider.updateProfilePhoto(base64Image);
        if (!context.mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diubah.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.error ?? 'Gagal mengubah foto profil.',
              ),
            ),
          );
        }
      }
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Apakah Anda yakin ingin keluar dari sesi ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // close dialog
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Absensi PPKD',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 PPKD Jakarta Pusat',
    );
  }

  String _getTrainingName(int? trainingId, AuthProvider provider) {
    if (trainingId == null) return '-';
    if (provider.trainings == null) return 'Memuat...';
    final training = provider.trainings?.cast().firstWhere(
      (t) => t.id == trainingId,
      orElse: () => null,
    );
    return training?.title ?? 'Unknown Training';
  }

  String _photoUrl(String value) {
    return value.startsWith('http')
        ? value
        : 'https://appabsensi.mobileprojp.com/storage/$value';
  }

  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isDark ? Colors.white : Colors.black87),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: titleColor),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 13))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (authProvider.isLoading && user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.error != null && user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(authProvider.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<AuthProvider>().fetchProfile(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Wrap the entire Scaffold in AnimatedBuilder so it instantly reacts to theme changes
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/main');
                }
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: ClipOval(
                        child:
                            (user?.profilePhoto != null &&
                                user!.profilePhoto!.isNotEmpty)
                            ? Image.network(
                                _photoUrl(user.profilePhoto!),
                                width: 92,
                                height: 92,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 92,
                                    height: 92,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 92,
                                height: 92,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _pickImage(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? '-',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Personal Info
                _buildSectionTitle(
                  'Informasi Pribadi',
                  trailing: TextButton(
                    onPressed: () {
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfilePage(user: user),
                          ),
                        ).then((value) {
                          if (!context.mounted) return;
                          context.read<AuthProvider>().fetchProfile();
                        });
                      }
                    },
                    child: const Text(
                      'EDIT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                _buildListTile(
                  isDark: isDark,
                  icon: Icons.person_outline,
                  iconBgColor: Colors.blue.withValues(alpha: 0.2),
                  title: 'NAMA LENGKAP',
                  subtitle: user?.name ?? '-',
                ),
                _buildListTile(
                  isDark: isDark,
                  icon: Icons.email_outlined,
                  iconBgColor: Colors.purple.withValues(alpha: 0.2),
                  title: 'EMAIL',
                  subtitle: user?.email ?? '-',
                ),
                _buildListTile(
                  isDark: isDark,
                  icon: Icons.wc_outlined,
                  iconBgColor: Colors.teal.withValues(alpha: 0.2),
                  title: 'JENIS KELAMIN',
                  subtitle: user?.jenisKelamin == 'L'
                      ? 'Laki-laki'
                      : (user?.jenisKelamin == 'P' ? 'Perempuan' : '-'),
                ),
                _buildListTile(
                  isDark: isDark,
                  icon: Icons.school_outlined,
                  iconBgColor: Colors.blue.withValues(alpha: 0.2),
                  title: 'JURUSAN',
                  subtitle: _getTrainingName(user?.trainingId, authProvider),
                ),
                _buildListTile(
                  isDark: isDark,
                  icon: Icons.groups_outlined,
                  iconBgColor: Colors.blue.withValues(alpha: 0.2),
                  title: 'ANGKATAN',
                  subtitle: user?.batchId != null ? '${user!.batchId}' : '-',
                ),

                // Security
                _buildSectionTitle('Keamanan'),
                _buildListTile(
                  isDark: isDark,
                  icon: Icons.lock_outline,
                  iconBgColor: Colors.blue.withValues(alpha: 0.2),
                  title: 'Ubah Password',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                Consumer<NotificationSettingsProvider>(
                  builder: (context, notifProvider, _) {
                    return _buildListTile(
                      isDark: isDark,
                      icon: Icons.notifications_outlined,
                      iconBgColor: Colors.green.withValues(alpha: 0.2),
                      title: 'Notifikasi',
                      subtitle: notifProvider.isNotifEnabled
                          ? 'Aktif'
                          : 'Nonaktif',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        notifProvider.toggleNotification(
                          !notifProvider.isNotifEnabled,
                        );
                      },
                    );
                  },
                ),

                // Language
                _buildSectionTitle('Bahasa'),
                Consumer<LanguageProvider>(
                  builder: (context, langProvider, _) {
                    return _buildListTile(
                      isDark: isDark,
                      icon: Icons.language,
                      iconBgColor: Colors.orange.withValues(alpha: 0.2),
                      title: 'Bahasa',
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: langProvider.language,
                          items: <String>['English', 'Indonesia'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              langProvider.setLanguage(newValue);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),

                // Appearance
                _buildSectionTitle('Tampilan'),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: const Text(
                      'Mode Gelap',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Gunakan tema gelap agar lebih nyaman di mata',
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: isDark ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () =>
                          ThemeController.instance.toggleTheme(!isDark),
                    ),
                    onTap: () => ThemeController.instance.toggleTheme(!isDark),
                  ),
                ),

                _buildListTile(
                  isDark: isDark,
                  icon: Icons.info_outline,
                  iconBgColor: Colors.blue.withValues(alpha: 0.2),
                  title: 'Tentang Aplikasi',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),

                // Sign Out
                const SizedBox(height: 16),
                _buildListTile(
                  isDark: isDark,
                  icon: Icons.logout, 
                  iconBgColor: Colors.red.withValues(alpha: 0.8),
                  title: 'Keluar',
                  titleColor: Colors.red,
                  onTap: () => _confirmSignOut(context),
                ),
                const SizedBox(height: 100), // Space for floating bottom bar
              ],
            ),
          ),
        );
      },
    );
  }
}
