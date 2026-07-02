import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

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
          const SnackBar(content: Text('Profile berhasil diupdate!')),
        );
        Navigator.pop(context, true); // return true to refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Gagal update profile.')),
        );
      }
    }
  }

  String? _validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) return 'Email tidak boleh kosong';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(val.trim())) return 'Format email tidak valid';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                validator: (val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: _validateEmail,
                // Email usually read-only or depends on backend rules
              ),
              const SizedBox(height: 16),
              provider.trainings == null 
                ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                : DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: provider.trainings!.any((t) => t.id == _selectedTrainingId) ? _selectedTrainingId : null,
                    decoration: const InputDecoration(labelText: 'Jurusan (Pelatihan)', border: OutlineInputBorder()),
                    items: provider.trainings!.map((t) {
                      return DropdownMenuItem<int>(
                        value: t.id,
                        child: Text(t.title ?? '-'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedTrainingId = val),
                  ),
              const SizedBox(height: 16),
              const Text(
                'Jenis Kelamin',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Laki-laki', style: TextStyle(fontSize: 14)),
                      value: 'L',
                      groupValue: _jenisKelamin,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _jenisKelamin = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Perempuan', style: TextStyle(fontSize: 14)),
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
                decoration: const InputDecoration(labelText: 'Angkatan', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
