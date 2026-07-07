import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../components/absensi_card.dart';
import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../utils/app_colors.dart';
import '../utils/error_translator.dart';
import '../l10n/app_localizations.dart';

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
  
  String _jenisKelamin = 'L'; // L or P
  final int _batchId = 1; // Default
  final int _trainingId = 16; // Default

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _requiredField(BuildContext context, String? value, String fieldName) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) return l10n.errFieldEmpty(fieldName);
    return null;
  }

  String? _requiredEmail(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.errEmailEmpty;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) return l10n.errEmailInvalid;
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final body = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'jenis_kelamin': _jenisKelamin,
      'profile_photo': '',
      'batch_id': _batchId,
      'training_id': _trainingId,
    };

    final success = await authProvider.register(body);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorTranslator.translate(context, authProvider.error!)),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.registerHeader,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.registerSubtitle,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              AbsensiCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: l10n.fullNameLabel,
                        icon: Icons.person_rounded,
                        controller: _nameController,
                        validator: (val) => _requiredField(context, val, l10n.fullNameLabel),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: l10n.emailLabel,
                        icon: Icons.email_rounded,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => _requiredEmail(context, v),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: l10n.passwordLabel,
                        icon: Icons.lock_rounded,
                        controller: _passwordController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _register(),
                        validator: (val) {
                          if (val == null || val.isEmpty) return l10n.errPasswordEmpty;
                          if (val.length < 6) return l10n.errPasswordMin;
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.genderLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(l10n.genderMale, style: const TextStyle(fontSize: 14)),
                              value: 'L',
                              groupValue: _jenisKelamin,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) => setState(() => _jenisKelamin = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(l10n.genderFemale, style: const TextStyle(fontSize: 14)),
                              value: 'P',
                              groupValue: _jenisKelamin,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) => setState(() => _jenisKelamin = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: l10n.registerButton,
                        icon: Icons.person_add_rounded,
                        loading: isLoading,
                        onPressed: _register,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pushReplacementNamed(context, '/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: Text(
                            l10n.hasAccountLogin,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
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
