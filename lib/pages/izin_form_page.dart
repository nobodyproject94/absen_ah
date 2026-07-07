import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../providers/attendance_provider.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/error_translator.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errSelectDateFirst), backgroundColor: AppColors.warning),
      );
      return;
    }
    if (_alasanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errPermitReasonEmpty), backgroundColor: AppColors.warning),
      );
      return;
    }

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
        SnackBar(content: Text(message ?? l10n.permitSuccess), backgroundColor: AppColors.success),
      );
      Navigator.pop(context); // Return to Dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorTranslator.translate(context, e)), backgroundColor: AppColors.danger),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.permitFormTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.permitFormHeader,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.permitFormSubtitle,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            Text(l10n.permitDateLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      _selectedDate == null ? l10n.selectDateHint : readableDate(_selectedDate!),
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
            
            CustomTextField(
              label: l10n.permitReasonFieldLabel,
              hintText: l10n.permitReasonHint,
              controller: _alasanController,
              icon: Icons.edit_document,
              maxLines: 4,
            ),
            const SizedBox(height: 40),
            
            PrimaryButton(
              label: l10n.submitPermitButton,
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
