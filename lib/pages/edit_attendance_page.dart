import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attendance_record.dart';
import '../providers/attendance_provider.dart';
import '../utils/app_colors.dart';
import '../l10n/app_localizations.dart';

class EditAttendancePage extends StatefulWidget {
  final AttendanceRecord record;

  const EditAttendancePage({super.key, required this.record});

  @override
  State<EditAttendancePage> createState() => _EditAttendancePageState();
}

class _EditAttendancePageState extends State<EditAttendancePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _dateController;
  late TextEditingController _reasonController;
  late TextEditingController _checkInTimeController;
  late TextEditingController _checkOutTimeController;
  late TextEditingController _checkInAddressController;
  late TextEditingController _checkOutAddressController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.record.date ?? '');
    _reasonController = TextEditingController(text: widget.record.alasanIzin ?? '');
    _checkInTimeController = TextEditingController(text: widget.record.checkInTime ?? '');
    _checkOutTimeController = TextEditingController(text: widget.record.checkOutTime ?? '');
    _checkInAddressController = TextEditingController(text: widget.record.checkInAddress ?? '');
    _checkOutAddressController = TextEditingController(text: widget.record.checkOutAddress ?? '');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _reasonController.dispose();
    _checkInTimeController.dispose();
    _checkOutTimeController.dispose();
    _checkInAddressController.dispose();
    _checkOutAddressController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay initialTime = const TimeOfDay(hour: 8, minute: 0);
    if (controller.text.isNotEmpty) {
      final parts = controller.text.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          initialTime = TimeOfDay(hour: h, minute: m);
        }
      }
    }
    
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (pickedTime != null) {
      final hStr = pickedTime.hour.toString().padLeft(2, '0');
      final mStr = pickedTime.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$hStr:$mStr';
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();
    if (_dateController.text.isNotEmpty) {
      initialDate = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    }
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (pickedDate != null) {
      final yStr = pickedDate.year.toString();
      final mStr = pickedDate.month.toString().padLeft(2, '0');
      final dStr = pickedDate.day.toString().padLeft(2, '0');
      setState(() {
        _dateController.text = '$yStr-$mStr-$dStr';
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      final isMasuk = widget.record.status == 'masuk';
      final checkInTimeVal = _checkInTimeController.text.trim();
      
      bool? isLateVal;
      if (isMasuk && checkInTimeVal.isNotEmpty) {
        isLateVal = checkInTimeVal.compareTo('08:00') > 0;
      }
      
      final updated = widget.record.copyWith(
        date: _dateController.text.trim(),
        alasanIzin: widget.record.isIzin ? _reasonController.text.trim() : null,
        checkInTime: isMasuk ? checkInTimeVal : null,
        checkOutTime: isMasuk ? _checkOutTimeController.text.trim() : null,
        checkInAddress: isMasuk ? _checkInAddressController.text.trim() : null,
        checkOutAddress: isMasuk ? _checkOutAddressController.text.trim() : null,
        isLate: isLateVal,
      );

      context.read<AttendanceProvider>().updateRecordLocally(updated);
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan berhasil disimpan! (Demo Mode)'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, updated);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isIzin = widget.record.isIzin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isIzin ? 'Edit Data Izin' : 'Edit Data Absen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (isIzin) ...[
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Izin',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  onTap: _selectDate,
                  validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Alasan Izin',
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan alasan...',
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                ),
              ] else ...[
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Absen',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _checkInTimeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Jam Masuk',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time_rounded),
                        ),
                        onTap: () => _selectTime(_checkInTimeController),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _checkOutTimeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Jam Pulang',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time_rounded),
                        ),
                        onTap: () => _selectTime(_checkOutTimeController),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _checkInAddressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Check-In',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _checkOutAddressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Check-Out',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
