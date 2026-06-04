<div align="center">

# Treemina Sleep

**Aplikasi mobile untuk mencatat, mengelola, dan memantau kualitas tidur pengguna.**

![Flutter](https://img.shields.io/badge/Flutter-Mobile_App-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Programming-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-34A853?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0%2B1-6C63FF?style=for-the-badge)

</div>

---

## Laporan Dokumentasi Aplikasi

Treemina Sleep adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu pengguna memantau kebiasaan tidur harian, mengatur target jadwal tidur, mencatat durasi tidur, dan melihat laporan kualitas tidur secara visual.

Aplikasi ini dibuat dengan pendekatan sederhana dan mudah digunakan. Pengguna dapat memulai sesi tidur, mengakhiri sesi tidur saat bangun, lalu melihat hasil durasi serta status kualitas tidur. Data akun, jadwal tidur, sesi tidur aktif, dan riwayat tidur tersimpan di Supabase sehingga dapat diakses kembali saat pengguna login dari perangkat berbeda.

Dokumentasi ini disusun sebagai dokumen serah terima aplikasi untuk client, mencakup gambaran produk, fitur, teknologi, alur penggunaan, instalasi, proses build, kebutuhan izin perangkat, validasi fitur, serta catatan operasional aplikasi.

---

## Daftar Isi

- [Ringkasan Proyek](#ringkasan-proyek)
- [Identitas Proyek](#identitas-proyek)
- [Tujuan Aplikasi](#tujuan-aplikasi)
- [Ruang Lingkup](#ruang-lingkup)
- [Fitur Aplikasi](#fitur-aplikasi)
- [Alur Penggunaan](#alur-penggunaan)
- [Struktur Navigasi](#struktur-navigasi)
- [Teknologi](#teknologi)
- [Struktur Folder](#struktur-folder)
- [Instalasi](#instalasi)
- [Build Aplikasi](#build-aplikasi)
- [Kebutuhan Izin](#kebutuhan-izin)
- [Penyimpanan Data](#penyimpanan-data)
- [Validasi Fitur](#validasi-fitur)
- [Catatan Operasional](#catatan-operasional)

---

## Ringkasan Proyek

| Aspek | Ringkasan |
| --- | --- |
| Fokus aplikasi | Membantu pengguna mencatat dan mengevaluasi pola tidur |
| Target pengguna | Pengguna umum yang ingin membangun rutinitas tidur lebih teratur |
| Mode penggunaan | Mobile app, digunakan langsung dari perangkat pengguna |
| Koneksi internet | Dibutuhkan untuk login dan sinkronisasi data Supabase |
| Penyimpanan | Supabase cloud database dan preferensi lokal perangkat |
| Status | Selesai dan siap diserahkan kepada client |

## Identitas Proyek

| Informasi | Keterangan |
| --- | --- |
| Nama aplikasi | Treemina Sleep |
| Jenis aplikasi | Sleep tracker dan sleep schedule manager |
| Platform | Android dan iOS |
| Framework | Flutter |
| Bahasa pemrograman | Dart |
| Versi aplikasi | 1.0.0+1 |
| Orientasi layar | Portrait |
| Penyimpanan data | Supabase cloud database |

---

## Tujuan Aplikasi

Treemina Sleep dikembangkan untuk memberikan pengalaman pencatatan tidur yang sederhana, visual, dan mudah dipahami.

Tujuan utama aplikasi:

- Membantu pengguna mencatat durasi tidur harian.
- Membantu pengguna memahami pola tidur melalui laporan visual.
- Memberikan status kualitas tidur berdasarkan durasi tidur.
- Memudahkan pengguna mengatur target waktu tidur dan bangun.
- Menyediakan pengalaman penggunaan yang nyaman melalui pilihan tema.
- Mendukung relaksasi pengguna melalui fitur musik.

## Ruang Lingkup

Aplikasi mencakup fitur inti yang dibutuhkan untuk manajemen tidur personal.

| Modul | Cakupan |
| --- | --- |
| Autentikasi | Registrasi, login, logout, dan penyimpanan status login |
| Pencatatan tidur | Mulai tidur, bangun, hitung durasi, dan simpan riwayat |
| Jadwal tidur | Pengaturan target jam tidur dan jam bangun |
| Laporan | Grafik durasi tidur dan daftar riwayat |
| Pengaturan | Tema, notifikasi, musik, dan akses file audio |
| Penyimpanan | Data utama tersimpan di Supabase |

Ketentuan ruang lingkup:

- Aplikasi menggunakan Supabase Auth untuk registrasi dan login.
- Data utama pengguna tersimpan di Supabase agar dapat digunakan lintas perangkat.
- Preferensi perangkat seperti tema dan pilihan musik tetap disimpan lokal pada perangkat.

---

## Fitur Aplikasi

### 1. Registrasi dan Login

Pengguna dapat membuat akun dan masuk ke aplikasi menggunakan Supabase Auth. Akun pengguna tersimpan di Supabase sehingga pengguna dapat login dari perangkat berbeda.

Fungsi:

- Registrasi pengguna baru.
- Login pengguna.
- Menyimpan status login.
- Logout dari aplikasi.

### 2. Dashboard Home

Halaman Home menjadi pusat aktivitas utama pengguna. Pada halaman ini pengguna dapat melihat sapaan personal, jadwal tidur, status tidur terakhir, dan tombol untuk memulai atau mengakhiri sesi tidur.

Fungsi:

- Menampilkan nama pengguna.
- Menampilkan jadwal target tidur dan bangun.
- Menampilkan status tidur terakhir.
- Memulai sesi tidur.
- Mengakhiri sesi tidur.
- Menampilkan hasil setelah pengguna bangun.

### 3. Pencatatan Tidur

Pengguna dapat menekan tombol mulai tidur saat akan tidur dan tombol bangun saat selesai tidur. Aplikasi akan menghitung durasi tidur secara otomatis.

Klasifikasi status tidur:

| Status | Kondisi |
| --- | --- |
| Bad Sleep | Durasi tidur kurang dari 7 jam |
| Excellent Sleep | Durasi tidur sekitar 7 sampai 8 jam |
| Over Sleep | Durasi tidur lebih dari 8 jam |

### 4. Perencanaan Jadwal Tidur

Halaman Plan digunakan untuk mengatur target waktu tidur dan waktu bangun sesuai rutinitas pengguna.

Fungsi:

- Mengatur target jam tidur.
- Mengatur target jam bangun.
- Menyimpan jadwal tidur.
- Menampilkan jadwal yang sudah disimpan.

### 5. Laporan Tidur

Halaman Report menampilkan data tidur dalam bentuk grafik dan daftar riwayat. Fitur ini membantu pengguna melihat gambaran pola tidur dari waktu ke waktu.

Fungsi:

- Grafik durasi tidur.
- Laporan mingguan.
- Laporan bulanan.
- Riwayat catatan tidur.
- Indikator warna untuk status kualitas tidur.

### 6. Pengaturan Aplikasi

Halaman Settings menyediakan konfigurasi aplikasi sesuai preferensi pengguna.

Fungsi:

- Mengaktifkan atau menonaktifkan notifikasi.
- Mengubah tema aplikasi.
- Memilih musik relaksasi.
- Memilih file audio dari perangkat.
- Logout dari aplikasi.

### 7. Tema Aplikasi

Aplikasi menyediakan beberapa pilihan tema:

| Tema | Keterangan |
| --- | --- |
| Light mode | Tampilan terang |
| Dark mode | Tampilan gelap |
| System mode | Mengikuti tema sistem perangkat |

### 8. Musik Relaksasi

Aplikasi menyediakan pilihan musik relaksasi dan mendukung file audio custom dari perangkat pengguna.

Pilihan musik bawaan:

| Track | Nama |
| --- | --- |
| ocean_waves | Ocean Waves |
| rainy_night | Rainy Night |
| calm_piano | Calm Piano |
| forest_breeze | Forest Breeze |

Catatan: aplikasi mendukung pemilihan file audio dari perangkat pengguna. Pilihan musik relaksasi bawaan tersedia pada tampilan aplikasi sebagai kategori musik yang dapat disesuaikan dengan aset audio client.

---

## Alur Penggunaan

```text
Buka aplikasi
    |
Registrasi atau login
    |
Masuk ke halaman utama
    |
Atur target tidur di halaman Plan
    |
Tekan mulai tidur saat akan tidur
    |
Tekan bangun saat selesai tidur
    |
Aplikasi menghitung durasi dan status tidur
    |
Lihat grafik dan riwayat di halaman Report
    |
Atur tema, notifikasi, dan musik di halaman Settings
```

Langkah penggunaan:

1. Pengguna membuka aplikasi Treemina Sleep.
2. Pengguna melakukan registrasi atau login.
3. Pengguna mengatur target jam tidur dan jam bangun di halaman Plan.
4. Saat akan tidur, pengguna menekan tombol mulai tidur di halaman Home.
5. Saat bangun, pengguna menekan tombol bangun.
6. Aplikasi menghitung durasi tidur dan menampilkan status kualitas tidur.
7. Pengguna melihat grafik dan riwayat tidur di halaman Report.
8. Pengguna mengubah tema, notifikasi, dan musik di halaman Settings.

## Struktur Navigasi

Aplikasi menggunakan bottom navigation dengan empat menu utama.

| Menu | Fungsi Utama | Hasil yang Dilihat Pengguna |
| --- | --- | --- |
| Home | Mencatat sesi tidur | Ringkasan, status tidur, dan tombol aksi |
| Plan | Mengatur target tidur | Jadwal tidur dan bangun |
| Report | Melihat laporan | Grafik dan riwayat tidur |
| Settings | Mengatur preferensi | Tema, notifikasi, musik, dan logout |

---

## Teknologi

| Teknologi | Fungsi |
| --- | --- |
| Flutter | Framework utama untuk membangun aplikasi mobile |
| Dart | Bahasa pemrograman aplikasi |
| Provider | State management |
| Supabase | Auth dan cloud database pengguna |
| Shared Preferences | Penyimpanan preferensi perangkat seperti tema dan musik |
| FL Chart | Visualisasi grafik laporan tidur |
| Flutter Local Notifications | Menampilkan notifikasi lokal |
| Audioplayers | Memutar file audio |
| File Picker | Memilih file audio dari perangkat |
| Intl | Format tanggal dan lokalisasi |
| Permission Handler | Pengelolaan izin perangkat |

Dependency utama:

```yaml
provider: ^6.1.2
shared_preferences: ^2.2.3
intl: ^0.19.0
fl_chart: ^0.68.0
flutter_local_notifications: ^17.2.3
audioplayers: ^6.1.0
file_picker: ^8.1.2
hive: ^2.2.3
hive_flutter: ^1.1.0
path_provider: ^2.1.4
permission_handler: ^11.3.1
supabase_flutter: ^2.12.4
```

---

## Struktur Folder

```text
lib/
  main.dart
  models/
    user_model.dart
    sleep_schedule_model.dart
    sleep_record_model.dart
  pages/
    login_page.dart
    register_page.dart
    main_page.dart
    home_page.dart
    sleep_plan_page.dart
    sleep_report_page.dart
    settings_page.dart
  providers/
    sleep_provider.dart
    theme_provider.dart
  services/
    storage_service.dart
    supabase_service.dart
    notification_service.dart
    music_service.dart
  utils/
    app_colors.dart
    app_theme.dart
    sleep_calculator.dart
  widgets/
    custom_button.dart
    theme_selector.dart
    sleep_visuals.dart
    sleep_record_item.dart
    sleep_chart.dart
    sleep_status_card.dart
    schedule_card.dart
supabase_schema.sql
```

| Folder | Keterangan |
| --- | --- |
| `models/` | Struktur data pengguna, jadwal, dan catatan tidur |
| `pages/` | Halaman tampilan aplikasi |
| `providers/` | Pengelolaan state aplikasi |
| `services/` | Layanan Supabase, penyimpanan lokal, notifikasi, dan musik |
| `utils/` | Warna, tema, dan kalkulator tidur |
| `widgets/` | Komponen UI yang digunakan ulang |
| `supabase_schema.sql` | Schema database Supabase untuk tabel dan policy |

---

## Instalasi

### Prasyarat

Pastikan perangkat pengembangan sudah memiliki:

- Flutter SDK versi stabil.
- Dart SDK.
- Android Studio atau Visual Studio Code.
- Android SDK.
- Emulator Android atau perangkat Android fisik.
- Xcode jika ingin menjalankan aplikasi di iOS.
- Git untuk mengambil source code dari repository.

Cek kesiapan environment:

```bash
flutter doctor
```

### Langkah Instalasi

1. Clone repository project.

```bash
git clone https://github.com/Adidtiasmara/TreeminaSleep.git
```

2. Masuk ke folder project.

```bash
cd TreeminaSleep
```

3. Ambil dependency Flutter.

```bash
flutter pub get
```

4. Siapkan database Supabase.

- Buat project baru di Supabase.
- Buka menu SQL Editor.
- Jalankan isi file `supabase_schema.sql`.
- Ambil Project URL dan Publishable Key dari dashboard Supabase.

5. Pastikan perangkat atau emulator terdeteksi.

```bash
flutter devices
```

6. Jalankan aplikasi pada perangkat yang tersedia dengan konfigurasi Supabase.

```bash
flutter run \
  --dart-define=SUPABASE_URL=<project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

Jika terdapat lebih dari satu perangkat, jalankan aplikasi menggunakan device id:

```bash
flutter run -d <device-id> \
  --dart-define=SUPABASE_URL=<project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

Contoh menjalankan aplikasi pada perangkat Android:

```bash
flutter run -d 102752535Q010426 \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxxxx
```

### Menjalankan di Android

Untuk menjalankan aplikasi di perangkat Android fisik:

1. Aktifkan Developer Options pada perangkat Android.
2. Aktifkan USB Debugging.
3. Sambungkan perangkat ke komputer menggunakan kabel USB.
4. Izinkan permintaan debugging yang muncul di perangkat.
5. Pastikan perangkat terdeteksi.

```bash
flutter devices
```

6. Jalankan aplikasi ke perangkat Android.

```bash
flutter run -d <device-id-android> \
  --dart-define=SUPABASE_URL=<project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

Jika menggunakan emulator Android, pastikan emulator sudah dinyalakan dari Android Studio atau command line sebelum menjalankan `flutter devices`.

---

## Build Aplikasi

### Build APK Android

```bash
flutter build apk \
  --dart-define=SUPABASE_URL=<project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Build Android App Bundle

```bash
flutter build appbundle \
  --dart-define=SUPABASE_URL=<project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

### Build iOS

Build iOS hanya dapat dilakukan di macOS dengan Xcode yang sudah dikonfigurasi.

```bash
flutter build ios \
  --dart-define=SUPABASE_URL=<project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

Untuk distribusi ke App Store, proses signing dan archive dilakukan melalui Xcode.

---

## Kebutuhan Izin

| Izin | Kegunaan |
| --- | --- |
| Internet | Login, registrasi, dan sinkronisasi data Supabase |
| Notifikasi | Menampilkan notifikasi status kualitas tidur |
| Akses file/audio | Memilih file musik dari perangkat |

Pada beberapa versi Android atau iOS, pengguna perlu memberikan izin secara manual saat aplikasi dijalankan.

## Penyimpanan Data

Aplikasi menggunakan Supabase untuk menyimpan data utama pengguna:

- Data pengguna.
- Status login.
- Jadwal target tidur dan bangun.
- Riwayat catatan tidur.
- Status sesi tidur yang sedang berjalan.

Aplikasi tetap menggunakan penyimpanan lokal perangkat untuk preferensi yang bersifat perangkat:

- Pengaturan notifikasi.
- Pengaturan tema.
- Pilihan musik.
- Path file musik custom.

Dengan Supabase, data utama pengguna tetap tersedia saat pengguna login dari perangkat lain menggunakan akun yang sama.

---

## Catatan Teknis

| Catatan | Keterangan |
| --- | --- |
| Orientasi aplikasi | Portrait |
| Bahasa tanggal | Indonesia |
| Internet | Dibutuhkan untuk autentikasi dan sinkronisasi Supabase |
| Backend | Menggunakan Supabase |
| Sinkronisasi data | Data utama dapat diakses lintas perangkat melalui akun pengguna |
| Ekspor laporan | Tidak termasuk dalam ruang lingkup versi ini |
| Musik bawaan | Dapat disesuaikan dengan aset audio client |

## Validasi Fitur

Daftar fitur berikut tersedia pada aplikasi dan dapat digunakan sebagai acuan serah terima:

| Fitur | Hasil yang Diharapkan | Status |
| --- | --- | --- |
| Registrasi pengguna | Pengguna baru dapat membuat akun Supabase | Tersedia |
| Login pengguna | Pengguna dapat masuk ke aplikasi | Tersedia |
| Mulai sesi tidur | Aplikasi menyimpan waktu mulai tidur | Tersedia |
| Akhiri sesi tidur | Aplikasi menyimpan waktu bangun | Tersedia |
| Perhitungan durasi | Aplikasi menghitung total durasi tidur | Tersedia |
| Status kualitas tidur | Aplikasi menampilkan kategori kualitas tidur | Tersedia |
| Jadwal tidur | Pengguna dapat mengatur jam tidur dan bangun | Tersedia |
| Laporan tidur | Aplikasi menampilkan grafik dan riwayat tidur | Tersedia |
| Pengaturan tema | Pengguna dapat memilih tema aplikasi | Tersedia |
| Notifikasi | Pengguna dapat mengaktifkan atau menonaktifkan notifikasi | Tersedia |
| Musik relaksasi | Pengguna dapat memilih file audio dari perangkat | Tersedia |
| Logout | Pengguna dapat keluar dari aplikasi | Tersedia |

---

## Catatan Operasional

Catatan berikut dapat digunakan oleh client atau tim teknis saat aplikasi digunakan dan dipelihara:

| Area | Catatan |
| --- | --- |
| Data | Data utama tersimpan di Supabase |
| Akun | Registrasi dan login berjalan melalui Supabase Auth |
| Notifikasi | Izin notifikasi perlu diberikan oleh pengguna pada perangkat |
| Musik | Pengguna dapat memilih file audio dari perangkat |
| Distribusi | File APK atau AAB dapat dibuat melalui perintah build Flutter |
| Pemeliharaan | Perubahan branding, audio, atau fitur tambahan dapat dilakukan pada source code Flutter |

## Kesimpulan

Treemina Sleep sudah memiliki fondasi fitur utama sebagai aplikasi pencatat dan pengelola kebiasaan tidur. Aplikasi dapat digunakan untuk mencatat sesi tidur, menilai kualitas tidur berdasarkan durasi, menampilkan laporan visual, serta menyediakan pengaturan personal seperti tema, notifikasi, dan musik relaksasi.

Dengan struktur project yang modular, aplikasi ini siap diserahkan kepada client sebagai aplikasi mobile berbasis Flutter yang dapat dijalankan, diuji, dan dibuild untuk kebutuhan distribusi.

---

<div align="center">

**Treemina Sleep**  
Dokumentasi aplikasi untuk kebutuhan laporan dan serah terima client.

</div>
