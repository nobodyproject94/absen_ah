// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'Riwayat';

  @override
  String get navProfile => 'Profil';

  @override
  String get appTitle => 'ABSENSI AH..';

  @override
  String get loginSubtitle =>
      'Masuk untuk mencatat kehadiran secara real-time berbasis lokasi.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccountRegister => 'Belum punya akun? Register di sini';

  @override
  String get errEmailEmpty => 'Email tidak boleh kosong';

  @override
  String get errEmailInvalid => 'Format email tidak valid';

  @override
  String get errPasswordEmpty => 'Password tidak boleh kosong';

  @override
  String get errPasswordMin => 'Password minimal 6 karakter';

  @override
  String get registerTitle => 'Registrasi';

  @override
  String get registerHeader => 'Buat Akun Baru';

  @override
  String get registerSubtitle => 'Daftar untuk mulai absensi hari ini.';

  @override
  String get fullNameLabel => 'Nama Lengkap';

  @override
  String get genderLabel => 'Jenis Kelamin';

  @override
  String get genderMale => 'Laki-laki';

  @override
  String get genderFemale => 'Perempuan';

  @override
  String get registerButton => 'Daftar';

  @override
  String get hasAccountLogin => 'Sudah punya akun? Login di sini';

  @override
  String errFieldEmpty(String field) {
    return '$field tidak boleh kosong';
  }

  @override
  String get greetingMorning => 'Selamat pagi';

  @override
  String get greetingAfternoon => 'Selamat siang';

  @override
  String get greetingEvening => 'Selamat sore';

  @override
  String get greetingNight => 'Selamat malam';

  @override
  String get defaultUser => 'Peserta PPKD';

  @override
  String get lightModeTooltip => 'Mode Terang';

  @override
  String get darkModeTooltip => 'Mode Gelap';

  @override
  String get todayAttendance => 'Absensi Hari Ini';

  @override
  String get timeAnomalyBadge => '⚠️ Anomali Waktu';

  @override
  String get statusLate => '• Terlambat';

  @override
  String get statusOnTime => '• Tepat Waktu';

  @override
  String get checkInLabel => 'Masuk';

  @override
  String get checkOutLabel => 'Pulang';

  @override
  String get permitButton => 'Ajukan Izin / Sakit';

  @override
  String get statTotal => 'Total';

  @override
  String get statPresent => 'Masuk';

  @override
  String get statPermit => 'Izin';

  @override
  String get tryAgainButton => 'Coba Lagi';

  @override
  String get historyTitle => 'Riwayat Absensi';

  @override
  String get emptyHistory => 'Belum ada riwayat absensi.';

  @override
  String get dateNotAvailable => 'Tanggal tidak tersedia';

  @override
  String get viewMapMenu => 'Lihat Map';

  @override
  String get deleteAttendanceMenu => 'Hapus Absen';

  @override
  String get permitReasonLabel => 'Alasan Izin:';

  @override
  String get errIdNotFound => 'ID absen tidak ditemukan.';

  @override
  String get deleteDialogTitle => 'Hapus Absen?';

  @override
  String get deleteDialogContent =>
      'Data absensi ini akan dihapus dari server. Lanjutkan?';

  @override
  String get cancelButton => 'Batal';

  @override
  String get deleteButton => 'Hapus';

  @override
  String get errCoordsNotAvailable => 'Koordinat lokasi tidak tersedia.';

  @override
  String get submitMapTitleCheckIn => 'Absen Masuk (Live Map)';

  @override
  String get submitMapTitleCheckOut => 'Absen Pulang (Live Map)';

  @override
  String get officeName => 'Kantor PPKD';

  @override
  String get officeDesc => 'Pusat Pelatihan Kerja Daerah';

  @override
  String yourPosition(String distance) {
    return 'Posisi Anda (${distance}m)';
  }

  @override
  String gpsAccuracy(String accuracy) {
    return 'Akurasi GPS: ±${accuracy}m';
  }

  @override
  String get detectingLocation => 'Mendeteksi lokasi & sinyal GPS real-time...';

  @override
  String get inGeofence => 'Dalam Radius Geofence';

  @override
  String get outGeofence => 'Di Luar Radius Kantor';

  @override
  String distanceInfo(String distance, String max) {
    return 'Jarak: ${distance}m (Max ${max}m)';
  }

  @override
  String get gpsWeak => '(Lemah >50m)';

  @override
  String get gpsGood => '(Baik)';

  @override
  String get tooFarButton => 'Terlalu Jauh dari Kantor';

  @override
  String get searchingGpsButton => 'Mencari Sinyal GPS Stabil...';

  @override
  String get confirmCheckInButton => 'Konfirmasi Absen Masuk';

  @override
  String get confirmCheckOutButton => 'Konfirmasi Absen Pulang';

  @override
  String get detailMapTitle => 'Lokasi Absensi';

  @override
  String get pointInfoTitle => 'Keterangan Titik Absensi:';

  @override
  String checkInPointInfo(String time, String address) {
    return 'Masuk ($time): $address';
  }

  @override
  String checkOutPointInfo(String time, String address) {
    return 'Pulang ($time): $address';
  }

  @override
  String get googleMapsTitle => 'Google Maps';

  @override
  String get searchingLocation => 'Mencari Lokasi...';

  @override
  String get yourLocation => 'Lokasi Anda';

  @override
  String get currentAddressLabel => 'Alamat Anda Saat Ini:';

  @override
  String get openInGoogleMaps => 'Buka di Google Maps';

  @override
  String errOpenExternalMap(String error) {
    return 'Gagal membuka peta eksternal: $error';
  }

  @override
  String get permitFormTitle => 'Pengajuan Izin';

  @override
  String get permitFormHeader => 'Formulir Izin / Tidak Masuk';

  @override
  String get permitFormSubtitle =>
      'Silakan lengkapi data di bawah ini dengan jelas.';

  @override
  String get permitDateLabel => 'Tanggal Izin';

  @override
  String get selectDateHint => 'Pilih Tanggal...';

  @override
  String get permitReasonFieldLabel => 'Alasan Izin';

  @override
  String get permitReasonHint =>
      'Contoh: Sakit demam berdarah (lampiran surat dokter)';

  @override
  String get submitPermitButton => 'Ajukan Izin';

  @override
  String get errSelectDateFirst => 'Pilih tanggal izin terlebih dahulu.';

  @override
  String get errPermitReasonEmpty => 'Alasan izin tidak boleh kosong.';

  @override
  String get pickFromGallery => 'Pilih dari Galeri';

  @override
  String get takePhotoCamera => 'Ambil Foto (Kamera)';

  @override
  String get photoUpdateSuccess => 'Foto profil berhasil diubah.';

  @override
  String get photoUpdateFailed => 'Gagal mengubah foto profil.';

  @override
  String get signOutTitle => 'Sign Out';

  @override
  String get signOutConfirm => 'Apakah Anda yakin ingin keluar dari sesi ini?';

  @override
  String get signOutButton => 'Keluar';

  @override
  String get personalInfoSection => 'Informasi Pribadi';

  @override
  String get editButton => 'EDIT';

  @override
  String get fieldFullName => 'NAMA LENGKAP';

  @override
  String get fieldEmail => 'EMAIL';

  @override
  String get fieldGender => 'JENIS KELAMIN';

  @override
  String get fieldMajor => 'JURUSAN';

  @override
  String get fieldBatch => 'ANGKATAN';

  @override
  String get securitySection => 'Keamanan';

  @override
  String get changePasswordMenu => 'Ubah Password';

  @override
  String get notificationMenu => 'Notifikasi';

  @override
  String get notifActive => 'Aktif';

  @override
  String get notifInactive => 'Nonaktif';

  @override
  String get languageSection => 'Bahasa';

  @override
  String get appearanceSection => 'Tampilan';

  @override
  String get darkModeMenu => 'Mode Gelap';

  @override
  String get darkModeDesc => 'Gunakan tema gelap agar lebih nyaman di mata';

  @override
  String get aboutAppMenu => 'Tentang Aplikasi';

  @override
  String get loadingText => 'Memuat...';

  @override
  String get editProfileTitle => 'Edit Profil';

  @override
  String get requiredField => 'Wajib diisi';

  @override
  String get majorFieldLabel => 'Jurusan (Pelatihan)';

  @override
  String get batchFieldLabel => 'Angkatan';

  @override
  String get saveChangesButton => 'Simpan Perubahan';

  @override
  String get profileUpdateSuccess => 'Profile berhasil diupdate!';

  @override
  String get profileUpdateFailed => 'Gagal update profile.';

  @override
  String get changePasswordTitle => 'Ubah Password';

  @override
  String get stubWarning =>
      'Perhatian: API /api/change-password belum tersedia. Operasi ini saat ini hanya berupa simulasi (stub).';

  @override
  String get currentPasswordLabel => 'Password Saat Ini';

  @override
  String get newPasswordLabel => 'Password Baru';

  @override
  String get confirmNewPasswordLabel => 'Konfirmasi Password Baru';

  @override
  String get errPasswordMismatch => 'Password tidak cocok';

  @override
  String get updatePasswordButton => 'Perbarui Password';

  @override
  String get passwordChangeSuccess => 'Password berhasil diubah.';

  @override
  String get passwordChangeFailed => 'Gagal merubah password.';

  @override
  String get errAlreadyCheckedInToday => 'Anda sudah absen hari ini.';

  @override
  String get errAlreadyPermittedToday =>
      'Anda sudah mengajukan izin pada tanggal ini.';

  @override
  String get errSessionExpired =>
      'Sesi Anda telah habis. Silakan login kembali.';

  @override
  String get errNetworkError =>
      'Terjadi kesalahan jaringan. Periksa koneksi internet Anda.';

  @override
  String get errServer500 =>
      'Server sedang bermasalah. Coba beberapa saat lagi.';

  @override
  String get errInvalidData => 'Data yang dikirim tidak valid.';

  @override
  String get errCheckInFailed => 'Gagal melakukan absen masuk.';

  @override
  String get errCheckOutFailed =>
      'Gagal melakukan absen pulang. Anda belum absen masuk hari ini.';

  @override
  String get errPermitFailed => 'Gagal mengajukan izin.';

  @override
  String get errDeleteFailed => 'Gagal menghapus data absensi.';

  @override
  String get errLoginFailed => 'Gagal login. Periksa email dan password Anda.';

  @override
  String get permitSuccess => 'Izin berhasil diajukan.';

  @override
  String get checkInSuccess => 'Absen masuk berhasil.';

  @override
  String get checkOutSuccess => 'Absen pulang berhasil.';

  @override
  String get deleteSuccess => 'Data absen berhasil dihapus.';
}
