import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/error_translator.dart';
import '../l10n/app_localizations.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = context.read<AuthProvider>();
    final success = await provider.changePassword(
      _oldPasswordController.text,
      _newPasswordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.passwordChangeSuccess)),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error != null ? ErrorTranslator.translate(context, provider.error!) : l10n.passwordChangeFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.amberAccent,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    l10n.stubWarning,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.currentPasswordLabel, border: const OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.newPasswordLabel, border: const OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.requiredField;
                  if (value.length < 6) return l10n.errPasswordMin;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.confirmNewPasswordLabel, border: const OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.requiredField;
                  if (value != _newPasswordController.text) return l10n.errPasswordMismatch;
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.updatePasswordButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
