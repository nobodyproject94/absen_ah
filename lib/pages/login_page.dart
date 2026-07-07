import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../components/absensi_card.dart';
import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../utils/app_colors.dart';
import '../utils/error_translator.dart';
import '../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _requiredEmail(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.errEmailEmpty;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return l10n.errEmailInvalid;
    }
    return null;
  }

  String? _requiredPassword(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;
    final text = value ?? '';
    if (text.isEmpty) return l10n.errPasswordEmpty;
    if (text.length < 6) return l10n.errPasswordMin;
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/absen_ah.png',
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginSubtitle,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              AbsensiCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                        onFieldSubmitted: (_) => _login(),
                        validator: (v) => _requiredPassword(context, v),
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: l10n.loginButton,
                        icon: Icons.login_rounded,
                        loading: isLoading,
                        onPressed: _login,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pushReplacementNamed(
                                context,
                                '/register',
                              ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: Text(
                          l10n.noAccountRegister,
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
