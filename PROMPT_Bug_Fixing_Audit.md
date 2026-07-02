# PROMPT: Audit & Perbaikan Bug Menyeluruh — Absensi PPKD (Flutter)

Gunakan prompt ini untuk meminta AI coding assistant (Claude Code, Cursor,
dll.) melakukan audit menyeluruh dan memperbaiki bug di project
`absensi_ppkd`, tanpa menebak-nebak atau merusak fitur yang sudah berjalan.

---

## PROMPT

Saya ingin kamu melakukan **audit menyeluruh dan perbaikan bug** pada project
Flutter `absensi_ppkd` (struktur Clean Architecture: `core/`, `data/`,
`presentation/`). Kerjakan secara sistematis, bertahap per kategori di bawah
ini, dan **jangan mengubah fitur atau alur bisnis yang sudah benar** — fokus
murni pada bug, konsistensi, dan kerapian kode.

### 0. Sebelum Mulai — Baseline Check

1. Jalankan `flutter analyze` dan `flutter pub outdated` terlebih dahulu.
   Tampilkan semua warning/error yang muncul sebagai daftar sebelum mulai
   memperbaiki apapun — saya ingin tahu skala masalahnya dulu.
2. Jalankan `flutter pub get` dan pastikan tidak ada dependency conflict.
3. Cek apakah project bisa di-build (`flutter build apk --debug` atau minimal
   `flutter run` di emulator) — catat error compile jika ada, ini prioritas
   nomor satu sebelum audit lanjutan lainnya.
4. Buat ringkasan struktur project saat ini (`lib/` tree) supaya kamu paham
   dependency antar file sebelum mengubah apapun.

### 1. Bug Kategori Kritis (Prioritas Tertinggi)

- **Null safety violations**: cari semua kemungkinan `null check operator (!)`
  yang dipakai tanpa jaminan nilai tidak null, yang berpotensi
  menyebabkan runtime crash (`Null check operator used on a null value`).
- **Unhandled exceptions**: pastikan **setiap** pemanggilan `ApiClient`
  (`get`, `post`, `put`, `delete`) di semua repository dibungkus try-catch
  yang benar dan meneruskan `ApiException` dengan pesan yang jelas ke
  Provider — jangan biarkan ada exception mentah yang bocor sampai ke UI
  dan menyebabkan app crash/freeze.
- **State management bugs**:
  - Cek semua `Provider`/`ChangeNotifier` — pastikan `notifyListeners()`
    selalu dipanggil setelah setiap perubahan state (loading, success,
    error), tidak ada state yang "diam" sehingga UI tidak update.
  - Cek kemungkinan **race condition**: misalnya pengguna menekan tombol
    Check-in dua kali dengan cepat sebelum request pertama selesai —
    pastikan tombol ter-disable saat `status == loading` di SEMUA tombol
    aksi (login, register, check-in, check-out, edit profile, delete absen).
  - Cek `setState()` yang dipanggil setelah widget ter-dispose
    (`This widget has been unmounted` error) — tambahkan pengecekan
    `if (!mounted) return;` di setiap `async` callback sebelum
    `setState`/`context` dipakai, terutama di halaman dengan `Navigator`.
- **Memory leaks**: pastikan semua `TextEditingController`,
  `AnimationController`, `StreamSubscription`, dan sejenisnya di-`dispose()`
  dengan benar di override method `dispose()` setiap `State` class.
- **Navigation bugs**:
  - Cek penggunaan `Navigator.push` vs `pushReplacement` vs
    `pushAndRemoveUntil` — pastikan konsisten (misal setelah Login/Register
    berhasil harus `pushAndRemoveUntil` agar user tidak bisa back ke halaman
    Login, setelah Logout juga sama).
  - Cek kemungkinan **double navigation** (tap tombol back/next dua kali
    cepat memicu dua kali push halaman yang sama).

### 2. Bug Kategori Data & API Integration

- Cocokkan **ulang** setiap field yang di-parse di `fromJson()` pada semua
  model (`UserModel`, `AbsenModel`, `AbsenStatsModel`, dll.) dengan response
  API asli — laporkan jika ada field yang mungkin salah nama, salah tipe
  (misal API kirim `String` tapi di-parse sebagai `int` langsung tanpa
  `int.tryParse`), atau field yang seharusnya nullable tapi dideklarasikan
  non-nullable (berisiko crash saat parsing).
- Cek semua tempat yang melakukan **type casting paksa**
  (`as Map<String, dynamic>`, `as List`, dll.) — ganti dengan casting yang
  aman (`is Map`, `Map<String, dynamic>.from(...)` dengan null check) agar
  tidak crash saat struktur response API sedikit berbeda dari yang
  diharapkan (misal field `data` bernilai `null` alih-alih objek kosong).
- Cek penanganan **HTTP status code** di `ApiClient` — pastikan behaviornya
  jelas dan konsisten untuk: `200/201` (sukses), `401` (unauthorized —
  idealnya trigger auto-logout & redirect ke Login, cek apakah ini sudah
  diimplementasikan; jika belum, ini bug fungsional yang perlu diperbaiki),
  `422` (validasi gagal — pastikan pesan error per-field ditampilkan, bukan
  pesan generik), `404`, `500`.
- Cek **duplikasi request**: pastikan tidak ada halaman yang memanggil API
  yang sama dua kali secara tidak sengaja (misal di `initState` DAN di
  `build()`, atau dipanggil ulang tanpa perlu setiap kali widget rebuild).
- Cek **timeout handling**: apakah ada timeout yang di-set untuk request
  HTTP? Jika belum ada, request yang menggantung tanpa batas waktu adalah
  bug — tambahkan timeout wajar (misal 15-30 detik) dan pesan error yang
  jelas jika timeout terjadi.

### 3. Bug Kategori Lokasi & Permission (Geolocator)

- Cek alur permission GPS: pastikan semua kemungkinan status
  (`denied`, `deniedForever`, `whileInUse`, `always`, service disabled)
  ditangani dengan pesan yang tepat, tidak ada state yang membuat app
  "diam" tanpa feedback ke user.
- Cek apakah ada kemungkinan **crash saat GPS timeout** (device di dalam
  ruangan/sinyal lemah) — pastikan ada timeout & fallback pada pemanggilan
  `Geolocator.getCurrentPosition()`.
- Pastikan koordinat yang dikirim ke API sudah dalam format yang benar
  (`double`, bukan `String` yang kebetulan valid saat testing tapi rawan
  error saat locale device berbeda, misal koma vs titik desimal).

### 4. Bug Kategori UI/UX

- Cek **overflow errors** (`RenderFlex overflowed`) terutama di layar kecil
  atau saat font system diperbesar (accessibility) — cek semua `Row`,
  `Column`, `Text` panjang tanpa `Expanded`/`Flexible`/`overflow` handling.
- Cek **keyboard menutup input field** — pastikan semua halaman form
  memakai `SingleChildScrollView` + `resizeToAvoidBottomInset` yang sesuai,
  supaya field tidak tertutup keyboard.
- Cek konsistensi **Dark Mode**: pastikan tidak ada warna yang di-hardcode
  (misal `Colors.white`/`Colors.black` langsung) yang menyebabkan elemen
  tidak terbaca saat mode gelap/terang — semua warna harus dari
  `Theme.of(context)` atau `AppTheme`.
- Cek **loading state yang hilang**: pastikan setiap tombol aksi
  menampilkan indikator loading dan disabled selama proses berlangsung
  (cross-check dengan poin race condition di atas).
- Cek **empty state** dan **error state** di semua halaman yang menampilkan
  list (History) — pastikan tidak menampilkan layar kosong tanpa pesan saat
  data belum ada atau gagal dimuat.
- Cek **pull-to-refresh** di halaman yang pakai `RefreshIndicator` — pastikan
  memang mengambil data terbaru, bukan cache lama yang seolah-olah refresh.

### 5. Bug Kategori Local Storage & Sesi

- Cek `SharedPreferences`: pastikan tidak ada key yang bentrok
  (misal key yang sama dipakai untuk dua data berbeda di file berbeda).
- Cek proses **logout**: pastikan BENAR-BENAR semua data sesi terhapus
  (token, nama user cache, dll.) — data yang tersisa bisa menyebabkan bug
  "user lama masih terlihat" setelah user lain login di device yang sama.
- Cek race condition saat **splash screen** membaca token dari
  `SharedPreferences` — pastikan tidak ada kemungkinan
  `Navigator` dipanggil sebelum widget ter-mount penuh.

### 6. Code Quality & Konsistensi (bukan bug fungsional, tapi wajib dibenahi)

- Hapus semua `import` yang tidak terpakai (unused imports).
- Hapus semua variabel/fungsi yang dideklarasikan tapi tidak pernah dipakai
  (dead code) — tapi **tanyakan dulu ke saya** jika ragu apakah suatu kode
  memang belum dipakai atau sengaja disiapkan untuk fitur mendatang.
- Pastikan penamaan konsisten (camelCase untuk variabel/method, PascalCase
  untuk class) sesuai konvensi Dart resmi.
- Cek apakah ada `print()` statement debugging yang tertinggal dan perlu
  dihapus atau diganti dengan proper logging sebelum production.
- Cek `TODO`/`FIXME` comment yang ada di kode — kumpulkan semua jadi satu
  daftar di akhir laporan, jangan langsung dihapus tanpa saya review.

### 7. Format Laporan yang Saya Inginkan

Setelah audit selesai, berikan laporan terstruktur seperti ini (jangan
langsung commit/ubah semua tanpa laporan ini dulu):

```
## Ringkasan Bug Ditemukan
| No | Kategori | File | Deskripsi Bug | Severity (Kritis/Sedang/Rendah) | Status (Diperbaiki/Perlu Konfirmasi) |
|----|----------|------|----------------|----------------------------------|----------------------------------------|
| 1  | ...      | ...  | ...            | ...                              | ...                                     |
```

Untuk bug ber-severity **Kritis**, perbaiki langsung dan tunjukkan diff
sebelum/sesudah. Untuk bug ber-severity **Sedang/Rendah** atau yang butuh
keputusan produk (misal: "apakah field X memang seharusnya opsional?"),
**tanyakan dulu ke saya sebelum mengubah**, jangan berasumsi.

### 8. Batasan Penting

- **Jangan mengubah** endpoint API atau struktur payload apapun tanpa
  konfirmasi — itu bukan bug, itu keputusan integrasi yang sudah
  divalidasi terhadap Postman Collection resmi sebelumnya.
- **Jangan mengganti** package/dependency inti (`provider`, `http`,
  `geolocator`, `google_maps_flutter`, `shared_preferences`) ke package lain
  tanpa saya minta — itu di luar scope "perbaikan bug".
- **Jangan menghapus** fitur apapun untuk "menyederhanakan" — kalau ada
  bug yang sulit diperbaiki tanpa mengubah alur fitur, laporkan dan
  tanyakan opsinya ke saya, jangan langsung dihapus.
- Setiap perbaikan harus disertai **komentar Dart singkat** yang menjelaskan
  bug apa yang diperbaiki dan kenapa (misal `// FIX: tambah null check untuk
  mencegah crash saat data.user bernilai null`).

---

**Catatan tambahan untuk kamu (bukan bagian prompt AI):**
- Sebelum menjalankan prompt ini, sebaiknya kamu sudah pernah menjalankan
  app minimal sekali dan mencatat bug spesifik yang kamu temui sendiri
  (misalnya: "app crash saat tekan absen pulang dua kali", "foto profil
  tidak muncul setelah update"). Kalau ada, **tempelkan daftar bug manual
  itu di awal percakapan** sebelum prompt di atas — supaya AI assistant
  bisa memprioritaskan bug nyata yang kamu alami, bukan cuma audit
  statis dari membaca kode.
- Kalau ada **error log/stack trace** dari `flutter run` atau crash report,
  sertakan juga — itu jauh lebih efektif daripada audit umum.
