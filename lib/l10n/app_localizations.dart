import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'ABSENSI AH..'**
  String get appTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk mencatat kehadiran secara real-time berbasis lokasi.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In id, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @noAccountRegister.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun? Register di sini'**
  String get noAccountRegister;

  /// No description provided for @errEmailEmpty.
  ///
  /// In id, this message translates to:
  /// **'Email tidak boleh kosong'**
  String get errEmailEmpty;

  /// No description provided for @errEmailInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get errEmailInvalid;

  /// No description provided for @errPasswordEmpty.
  ///
  /// In id, this message translates to:
  /// **'Password tidak boleh kosong'**
  String get errPasswordEmpty;

  /// No description provided for @errPasswordMin.
  ///
  /// In id, this message translates to:
  /// **'Password minimal 6 karakter'**
  String get errPasswordMin;

  /// No description provided for @registerTitle.
  ///
  /// In id, this message translates to:
  /// **'Registrasi'**
  String get registerTitle;

  /// No description provided for @registerHeader.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun Baru'**
  String get registerHeader;

  /// No description provided for @registerSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar untuk mulai absensi hari ini.'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get fullNameLabel;

  /// No description provided for @genderLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenis Kelamin'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In id, this message translates to:
  /// **'Laki-laki'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In id, this message translates to:
  /// **'Perempuan'**
  String get genderFemale;

  /// No description provided for @registerButton.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get registerButton;

  /// No description provided for @hasAccountLogin.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun? Login di sini'**
  String get hasAccountLogin;

  /// No description provided for @errFieldEmpty.
  ///
  /// In id, this message translates to:
  /// **'{field} tidak boleh kosong'**
  String errFieldEmpty(String field);

  /// No description provided for @greetingMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat pagi'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat siang'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In id, this message translates to:
  /// **'Selamat sore'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In id, this message translates to:
  /// **'Selamat malam'**
  String get greetingNight;

  /// No description provided for @defaultUser.
  ///
  /// In id, this message translates to:
  /// **'Peserta PPKD'**
  String get defaultUser;

  /// No description provided for @lightModeTooltip.
  ///
  /// In id, this message translates to:
  /// **'Mode Terang'**
  String get lightModeTooltip;

  /// No description provided for @darkModeTooltip.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get darkModeTooltip;

  /// No description provided for @todayAttendance.
  ///
  /// In id, this message translates to:
  /// **'Absensi Hari Ini'**
  String get todayAttendance;

  /// No description provided for @timeAnomalyBadge.
  ///
  /// In id, this message translates to:
  /// **'⚠️ Anomali Waktu'**
  String get timeAnomalyBadge;

  /// No description provided for @statusLate.
  ///
  /// In id, this message translates to:
  /// **'• Terlambat'**
  String get statusLate;

  /// No description provided for @statusOnTime.
  ///
  /// In id, this message translates to:
  /// **'• Tepat Waktu'**
  String get statusOnTime;

  /// No description provided for @checkInLabel.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get checkInLabel;

  /// No description provided for @checkOutLabel.
  ///
  /// In id, this message translates to:
  /// **'Pulang'**
  String get checkOutLabel;

  /// No description provided for @permitButton.
  ///
  /// In id, this message translates to:
  /// **'Ajukan Izin / Sakit'**
  String get permitButton;

  /// No description provided for @statTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get statTotal;

  /// No description provided for @statPresent.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get statPresent;

  /// No description provided for @statPermit.
  ///
  /// In id, this message translates to:
  /// **'Izin'**
  String get statPermit;

  /// No description provided for @tryAgainButton.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get tryAgainButton;

  /// No description provided for @historyTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Absensi'**
  String get historyTitle;

  /// No description provided for @emptyHistory.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat absensi.'**
  String get emptyHistory;

  /// No description provided for @dateNotAvailable.
  ///
  /// In id, this message translates to:
  /// **'Tanggal tidak tersedia'**
  String get dateNotAvailable;

  /// No description provided for @viewMapMenu.
  ///
  /// In id, this message translates to:
  /// **'Lihat Map'**
  String get viewMapMenu;

  /// No description provided for @deleteAttendanceMenu.
  ///
  /// In id, this message translates to:
  /// **'Hapus Absen'**
  String get deleteAttendanceMenu;

  /// No description provided for @permitReasonLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan Izin:'**
  String get permitReasonLabel;

  /// No description provided for @errIdNotFound.
  ///
  /// In id, this message translates to:
  /// **'ID absen tidak ditemukan.'**
  String get errIdNotFound;

  /// No description provided for @deleteDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Absen?'**
  String get deleteDialogTitle;

  /// No description provided for @deleteDialogContent.
  ///
  /// In id, this message translates to:
  /// **'Data absensi ini akan dihapus dari server. Lanjutkan?'**
  String get deleteDialogContent;

  /// No description provided for @cancelButton.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get deleteButton;

  /// No description provided for @errCoordsNotAvailable.
  ///
  /// In id, this message translates to:
  /// **'Koordinat lokasi tidak tersedia.'**
  String get errCoordsNotAvailable;

  /// No description provided for @submitMapTitleCheckIn.
  ///
  /// In id, this message translates to:
  /// **'Absen Masuk (Live Map)'**
  String get submitMapTitleCheckIn;

  /// No description provided for @submitMapTitleCheckOut.
  ///
  /// In id, this message translates to:
  /// **'Absen Pulang (Live Map)'**
  String get submitMapTitleCheckOut;

  /// No description provided for @officeName.
  ///
  /// In id, this message translates to:
  /// **'Kantor PPKD'**
  String get officeName;

  /// No description provided for @officeDesc.
  ///
  /// In id, this message translates to:
  /// **'Pusat Pelatihan Kerja Daerah'**
  String get officeDesc;

  /// No description provided for @yourPosition.
  ///
  /// In id, this message translates to:
  /// **'Posisi Anda ({distance}m)'**
  String yourPosition(String distance);

  /// No description provided for @gpsAccuracy.
  ///
  /// In id, this message translates to:
  /// **'Akurasi GPS: ±{accuracy}m'**
  String gpsAccuracy(String accuracy);

  /// No description provided for @detectingLocation.
  ///
  /// In id, this message translates to:
  /// **'Mendeteksi lokasi & sinyal GPS real-time...'**
  String get detectingLocation;

  /// No description provided for @inGeofence.
  ///
  /// In id, this message translates to:
  /// **'Dalam Radius Geofence'**
  String get inGeofence;

  /// No description provided for @outGeofence.
  ///
  /// In id, this message translates to:
  /// **'Di Luar Radius Kantor'**
  String get outGeofence;

  /// No description provided for @distanceInfo.
  ///
  /// In id, this message translates to:
  /// **'Jarak: {distance}m (Max {max}m)'**
  String distanceInfo(String distance, String max);

  /// No description provided for @gpsWeak.
  ///
  /// In id, this message translates to:
  /// **'(Lemah >50m)'**
  String get gpsWeak;

  /// No description provided for @gpsGood.
  ///
  /// In id, this message translates to:
  /// **'(Baik)'**
  String get gpsGood;

  /// No description provided for @tooFarButton.
  ///
  /// In id, this message translates to:
  /// **'Terlalu Jauh dari Kantor'**
  String get tooFarButton;

  /// No description provided for @searchingGpsButton.
  ///
  /// In id, this message translates to:
  /// **'Mencari Sinyal GPS Stabil...'**
  String get searchingGpsButton;

  /// No description provided for @confirmCheckInButton.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Absen Masuk'**
  String get confirmCheckInButton;

  /// No description provided for @confirmCheckOutButton.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Absen Pulang'**
  String get confirmCheckOutButton;

  /// No description provided for @detailMapTitle.
  ///
  /// In id, this message translates to:
  /// **'Lokasi Absensi'**
  String get detailMapTitle;

  /// No description provided for @pointInfoTitle.
  ///
  /// In id, this message translates to:
  /// **'Keterangan Titik Absensi:'**
  String get pointInfoTitle;

  /// No description provided for @checkInPointInfo.
  ///
  /// In id, this message translates to:
  /// **'Masuk ({time}): {address}'**
  String checkInPointInfo(String time, String address);

  /// No description provided for @checkOutPointInfo.
  ///
  /// In id, this message translates to:
  /// **'Pulang ({time}): {address}'**
  String checkOutPointInfo(String time, String address);

  /// No description provided for @googleMapsTitle.
  ///
  /// In id, this message translates to:
  /// **'Google Maps'**
  String get googleMapsTitle;

  /// No description provided for @searchingLocation.
  ///
  /// In id, this message translates to:
  /// **'Mencari Lokasi...'**
  String get searchingLocation;

  /// No description provided for @yourLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi Anda'**
  String get yourLocation;

  /// No description provided for @currentAddressLabel.
  ///
  /// In id, this message translates to:
  /// **'Alamat Anda Saat Ini:'**
  String get currentAddressLabel;

  /// No description provided for @openInGoogleMaps.
  ///
  /// In id, this message translates to:
  /// **'Buka di Google Maps'**
  String get openInGoogleMaps;

  /// No description provided for @errOpenExternalMap.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuka peta eksternal: {error}'**
  String errOpenExternalMap(String error);

  /// No description provided for @permitFormTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengajuan Izin'**
  String get permitFormTitle;

  /// No description provided for @permitFormHeader.
  ///
  /// In id, this message translates to:
  /// **'Formulir Izin / Tidak Masuk'**
  String get permitFormHeader;

  /// No description provided for @permitFormSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Silakan lengkapi data di bawah ini dengan jelas.'**
  String get permitFormSubtitle;

  /// No description provided for @permitDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Izin'**
  String get permitDateLabel;

  /// No description provided for @selectDateHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih Tanggal...'**
  String get selectDateHint;

  /// No description provided for @permitReasonFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan Izin'**
  String get permitReasonFieldLabel;

  /// No description provided for @permitReasonHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Sakit demam berdarah (lampiran surat dokter)'**
  String get permitReasonHint;

  /// No description provided for @submitPermitButton.
  ///
  /// In id, this message translates to:
  /// **'Ajukan Izin'**
  String get submitPermitButton;

  /// No description provided for @errSelectDateFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal izin terlebih dahulu.'**
  String get errSelectDateFirst;

  /// No description provided for @errPermitReasonEmpty.
  ///
  /// In id, this message translates to:
  /// **'Alasan izin tidak boleh kosong.'**
  String get errPermitReasonEmpty;

  /// No description provided for @pickFromGallery.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari Galeri'**
  String get pickFromGallery;

  /// No description provided for @takePhotoCamera.
  ///
  /// In id, this message translates to:
  /// **'Ambil Foto (Kamera)'**
  String get takePhotoCamera;

  /// No description provided for @photoUpdateSuccess.
  ///
  /// In id, this message translates to:
  /// **'Foto profil berhasil diubah.'**
  String get photoUpdateSuccess;

  /// No description provided for @photoUpdateFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengubah foto profil.'**
  String get photoUpdateFailed;

  /// No description provided for @signOutTitle.
  ///
  /// In id, this message translates to:
  /// **'Sign Out'**
  String get signOutTitle;

  /// No description provided for @signOutConfirm.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin keluar dari sesi ini?'**
  String get signOutConfirm;

  /// No description provided for @signOutButton.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get signOutButton;

  /// No description provided for @personalInfoSection.
  ///
  /// In id, this message translates to:
  /// **'Informasi Pribadi'**
  String get personalInfoSection;

  /// No description provided for @editButton.
  ///
  /// In id, this message translates to:
  /// **'EDIT'**
  String get editButton;

  /// No description provided for @fieldFullName.
  ///
  /// In id, this message translates to:
  /// **'NAMA LENGKAP'**
  String get fieldFullName;

  /// No description provided for @fieldEmail.
  ///
  /// In id, this message translates to:
  /// **'EMAIL'**
  String get fieldEmail;

  /// No description provided for @fieldGender.
  ///
  /// In id, this message translates to:
  /// **'JENIS KELAMIN'**
  String get fieldGender;

  /// No description provided for @fieldMajor.
  ///
  /// In id, this message translates to:
  /// **'JURUSAN'**
  String get fieldMajor;

  /// No description provided for @fieldBatch.
  ///
  /// In id, this message translates to:
  /// **'ANGKATAN'**
  String get fieldBatch;

  /// No description provided for @securitySection.
  ///
  /// In id, this message translates to:
  /// **'Keamanan'**
  String get securitySection;

  /// No description provided for @changePasswordMenu.
  ///
  /// In id, this message translates to:
  /// **'Ubah Password'**
  String get changePasswordMenu;

  /// No description provided for @notificationMenu.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notificationMenu;

  /// No description provided for @notifActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get notifActive;

  /// No description provided for @notifInactive.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get notifInactive;

  /// No description provided for @languageSection.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get languageSection;

  /// No description provided for @appearanceSection.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get appearanceSection;

  /// No description provided for @darkModeMenu.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get darkModeMenu;

  /// No description provided for @darkModeDesc.
  ///
  /// In id, this message translates to:
  /// **'Gunakan tema gelap agar lebih nyaman di mata'**
  String get darkModeDesc;

  /// No description provided for @aboutAppMenu.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get aboutAppMenu;

  /// No description provided for @loadingText.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get loadingText;

  /// No description provided for @editProfileTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Profil'**
  String get editProfileTitle;

  /// No description provided for @requiredField.
  ///
  /// In id, this message translates to:
  /// **'Wajib diisi'**
  String get requiredField;

  /// No description provided for @majorFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Jurusan (Pelatihan)'**
  String get majorFieldLabel;

  /// No description provided for @batchFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Angkatan'**
  String get batchFieldLabel;

  /// No description provided for @saveChangesButton.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get saveChangesButton;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In id, this message translates to:
  /// **'Profile berhasil diupdate!'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal update profile.'**
  String get profileUpdateFailed;

  /// No description provided for @changePasswordTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Password'**
  String get changePasswordTitle;

  /// No description provided for @stubWarning.
  ///
  /// In id, this message translates to:
  /// **'Perhatian: API /api/change-password belum tersedia. Operasi ini saat ini hanya berupa simulasi (stub).'**
  String get stubWarning;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Password Saat Ini'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Password Baru'**
  String get newPasswordLabel;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Password Baru'**
  String get confirmNewPasswordLabel;

  /// No description provided for @errPasswordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Password tidak cocok'**
  String get errPasswordMismatch;

  /// No description provided for @updatePasswordButton.
  ///
  /// In id, this message translates to:
  /// **'Perbarui Password'**
  String get updatePasswordButton;

  /// No description provided for @passwordChangeSuccess.
  ///
  /// In id, this message translates to:
  /// **'Password berhasil diubah.'**
  String get passwordChangeSuccess;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal merubah password.'**
  String get passwordChangeFailed;

  /// No description provided for @errAlreadyCheckedInToday.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah absen hari ini.'**
  String get errAlreadyCheckedInToday;

  /// No description provided for @errAlreadyPermittedToday.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah mengajukan izin pada tanggal ini.'**
  String get errAlreadyPermittedToday;

  /// No description provided for @errSessionExpired.
  ///
  /// In id, this message translates to:
  /// **'Sesi Anda telah habis. Silakan login kembali.'**
  String get errSessionExpired;

  /// No description provided for @errNetworkError.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan jaringan. Periksa koneksi internet Anda.'**
  String get errNetworkError;

  /// No description provided for @errServer500.
  ///
  /// In id, this message translates to:
  /// **'Server sedang bermasalah. Coba beberapa saat lagi.'**
  String get errServer500;

  /// No description provided for @errInvalidData.
  ///
  /// In id, this message translates to:
  /// **'Data yang dikirim tidak valid.'**
  String get errInvalidData;

  /// No description provided for @errCheckInFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal melakukan absen masuk.'**
  String get errCheckInFailed;

  /// No description provided for @errCheckOutFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal melakukan absen pulang. Anda belum absen masuk hari ini.'**
  String get errCheckOutFailed;

  /// No description provided for @errPermitFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengajukan izin.'**
  String get errPermitFailed;

  /// No description provided for @errDeleteFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus data absensi.'**
  String get errDeleteFailed;

  /// No description provided for @errLoginFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal login. Periksa email dan password Anda.'**
  String get errLoginFailed;

  /// No description provided for @permitSuccess.
  ///
  /// In id, this message translates to:
  /// **'Izin berhasil diajukan.'**
  String get permitSuccess;

  /// No description provided for @checkInSuccess.
  ///
  /// In id, this message translates to:
  /// **'Absen masuk berhasil.'**
  String get checkInSuccess;

  /// No description provided for @checkOutSuccess.
  ///
  /// In id, this message translates to:
  /// **'Absen pulang berhasil.'**
  String get checkOutSuccess;

  /// No description provided for @deleteSuccess.
  ///
  /// In id, this message translates to:
  /// **'Data absen berhasil dihapus.'**
  String get deleteSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
