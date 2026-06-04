# Treemina Sleep

Treemina Sleep adalah aplikasi Flutter untuk membantu pengguna memantau kebiasaan tidur, mengatur jadwal tidur, melihat laporan durasi tidur, dan menyesuaikan pengalaman aplikasi melalui tema, notifikasi, serta musik relaksasi.

Aplikasi ini menyimpan data secara lokal di perangkat, sehingga pengguna dapat mencatat sesi tidur tanpa membutuhkan server eksternal.

## Fitur Utama

- Registrasi dan login pengguna lokal.
- Pencatatan sesi tidur dengan tombol mulai tidur dan bangun.
- Perhitungan durasi tidur otomatis.
- Status kualitas tidur berdasarkan durasi tidur.
- Pengaturan target jam tidur dan jam bangun.
- Grafik laporan tidur mingguan dan bulanan.
- Riwayat catatan tidur.
- Notifikasi hasil kualitas tidur.
- Pilihan tema terang, gelap, atau mengikuti sistem.
- Musik relaksasi bawaan dan dukungan memilih file audio sendiri.

## Teknologi

- Flutter
- Dart
- Provider untuk state management
- Shared Preferences untuk penyimpanan lokal
- FL Chart untuk grafik laporan tidur
- Flutter Local Notifications untuk notifikasi
- Audioplayers dan File Picker untuk fitur musik

## Prasyarat

Pastikan perangkat pengembangan sudah memiliki:

- Flutter SDK versi stabil
- Dart SDK
- Android Studio atau Visual Studio Code
- Android SDK untuk menjalankan aplikasi Android
- Xcode jika ingin menjalankan aplikasi di iOS
- Emulator Android, iOS Simulator, atau perangkat fisik

Cek instalasi Flutter dengan perintah:

```bash
flutter doctor
```

Pastikan semua kebutuhan platform yang ingin digunakan sudah berstatus siap.

## Instalasi

1. Clone atau buka folder proyek ini.

```bash
git clone <url-repository>
cd treemina_sleep
```

2. Ambil semua dependency Flutter.

```bash
flutter pub get
```

3. Jalankan aplikasi pada emulator atau perangkat yang terhubung.

```bash
flutter run
```

Jika ada lebih dari satu perangkat, lihat daftar perangkat terlebih dahulu:

```bash
flutter devices
```

Lalu jalankan ke perangkat tertentu:

```bash
flutter run -d <device-id>
```

## Cara Penggunaan

1. Buka aplikasi Treemina Sleep.
2. Daftar akun baru atau login jika sudah pernah mendaftar.
3. Pada halaman Home, tekan tombol mulai tidur saat akan tidur.
4. Saat bangun, tekan tombol bangun untuk menyimpan sesi tidur.
5. Aplikasi akan menghitung durasi tidur dan menampilkan status kualitas tidur.
6. Buka halaman Plan untuk mengatur target jam tidur dan jam bangun.
7. Buka halaman Report untuk melihat grafik dan riwayat tidur.
8. Buka halaman Settings untuk mengatur notifikasi, tema aplikasi, dan musik relaksasi.

## Build Aplikasi

Untuk membuat file APK Android:

```bash
flutter build apk
```

Hasil build berada di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Untuk membuat Android App Bundle:

```bash
flutter build appbundle
```

Untuk build iOS, jalankan dari macOS dengan Xcode yang sudah dikonfigurasi:

```bash
flutter build ios
```

## Struktur Folder

```text
lib/
  main.dart                 Entry point aplikasi
  models/                   Model data pengguna, jadwal, dan catatan tidur
  pages/                    Halaman utama aplikasi
  providers/                State management aplikasi
  services/                 Layanan penyimpanan, notifikasi, dan musik
  utils/                    Tema, warna, dan kalkulator tidur
  widgets/                  Komponen UI reusable
```

## Catatan

- Data pengguna, jadwal, pengaturan, dan riwayat tidur disimpan secara lokal di perangkat.
- Fitur notifikasi membutuhkan izin notifikasi dari perangkat.
- Fitur memilih musik sendiri membutuhkan akses file/audio pada perangkat.
