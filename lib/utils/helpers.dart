String dd(int value) => value.toString().padLeft(2, '0');

String readableDate(DateTime date) {
  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  const months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
}

String readableTime(DateTime date) => '${dd(date.hour)}:${dd(date.minute)}';

String extractApiMessage(dynamic data, String fallback) {
  try {
    if (data is Map && data['message'] != null) return data['message'].toString();
  } catch (_) {}
  return fallback;
}
