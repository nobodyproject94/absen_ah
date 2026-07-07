import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../utils/error_translator.dart';
import '../l10n/app_localizations.dart';

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
  late TextEditingController _batchIdController;
  
  int? _selectedTrainingId;
  String _jenisKelamin = 'L';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _batchIdController = TextEditingController(text: widget.user.batchId?.toString() ?? '');
    
    final provider = context.read<AuthProvider>();
    _selectedTrainingId = widget.user.trainingId;
    _jenisKelamin = widget.user.jenisKelamin ?? 'L';
    if (provider.trainings == null) {
      provider.fetchTrainings();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _batchIdController.dispose();
    super.dispose();
  }

  void _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final provider = context.read<AuthProvider>();
    
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

    final success = await provider.updateProfile(body);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdateSuccess)),
        );
        Navigator.pop(context, true); // return true to refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error != null ? ErrorTranslator.translate(context, provider.error!) : l10n.profileUpdateFailed)),
        );
      }
    }
  }

  String? _validateEmail(BuildContext context, String? val) {
    final l10n = AppLocalizations.of(context)!;
    if (val == null || val.trim().isEmpty) return l10n.errEmailEmpty;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(val.trim())) return l10n.errEmailInvalid;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfileTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.fullNameLabel, border: const OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.emailLabel, border: const OutlineInputBorder()),
                validator: (val) => _validateEmail(context, val),
              ),
              const SizedBox(height: 16),
              provider.trainings == null 
                ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                : DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: provider.trainings!.any((t) => t.id == _selectedTrainingId) ? _selectedTrainingId : null,
                    decoration: InputDecoration(labelText: l10n.majorFieldLabel, border: const OutlineInputBorder()),
                    items: provider.trainings!.map((t) {
                      return DropdownMenuItem<int>(
                        value: t.id,
                        child: Text(t.title ?? '-'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedTrainingId = val),
                  ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _batchIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.batchFieldLabel, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.saveChangesButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
