import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../providers/attendance_provider.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';

class IzinFormPage extends StatefulWidget {
  const IzinFormPage({super.key});

  @override
  State<IzinFormPage> createState() => _IzinFormPageState();
}

class _IzinFormPageState extends State<IzinFormPage> {
  final _alasanController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal izin terlebih dahulu.'), backgroundColor: AppColors.warning),
      );
      return;
    }
    if (_alasanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan izin tidak boleh kosong.'), backgroundColor: AppColors.warning),
      );
      return;
    }

    // Format date to YYYY-MM-DD
    final y = _selectedDate!.year;
    final m = _selectedDate!.month.toString().padLeft(2, '0');
    final d = _selectedDate!.day.toString().padLeft(2, '0');
    final dateStr = '$y-$m-$d';

    final provider = context.read<AttendanceProvider>();
    try {
      final message = await provider.submitIzin(
        date: dateStr,
        alasan: _alasanController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Izin berhasil diajukan.'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context); // Return to Dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Izin'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Formulir Izin / Tidak Masuk',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan lengkapi data di bawah ini dengan jelas.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Date Picker Field
            const Text('Tanggal Izin', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null ? 'Pilih Tanggal...' : readableDate(_selectedDate!),
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate == null ? Colors.grey : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Alasan Text Field
            CustomTextField(
              label: 'Alasan Izin',
              hintText: 'Contoh: Sakit demam berdarah (lampiran surat dokter)',
              controller: _alasanController,
              icon: Icons.edit_document,
              maxLines: 4,
            ),
            const SizedBox(height: 40),
            
            PrimaryButton(
              label: 'Ajukan Izin',
              icon: Icons.send_rounded,
              loading: provider.isSubmittingIzin,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
