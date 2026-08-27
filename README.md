# HerAlth

Flutter app untuk pencatatan siklus dan check-up berbasis pola. Alur check-up mengikuti desain referensi: landing → symptoms → ultrasound (opsional) → review → Gemini analysis → results.

## Menjalankan project

1. Salin `.env.example` menjadi `.env`.
2. Isi `GEMINI_API_KEY` dengan key Google AI Studio.
3. Jalankan `flutter pub get`, lalu `flutter run`.

Alternatif untuk CI/build tanpa file `.env`:

```bash
flutter run --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY"
```

`GEMINI_MODEL` dapat diubah dari `.env` atau `--dart-define`. Default dan fallback menggunakan `gemini-3.5-flash`; fallback dapat diubah melalui `GEMINI_FALLBACK_MODEL`. Untuk HTTP 408, 429, dan 5xx, client mencoba ulang hingga tiga kali dengan jeda 1, 2, lalu 4 detik sebelum mencoba model fallback satu kali. Client menggunakan endpoint Gemini `generateContent` multimodal dan mengirim file sebagai `inline_data`.

## Validasi ultrasound

Upload menerima JPG/JPEG, PNG, atau PDF hingga 10 MB. Sebelum file dipakai, aplikasi memeriksa file kosong, extension, signature bytes, dan apakah image dapat di-decode dengan ukuran minimum yang layak. Saat analisis, Gemini juga diminta menolak foto/screenshot/random image yang bukan scan klinis.

Key `.env` tidak boleh di-commit. Untuk production, API key sebaiknya dipindahkan ke backend/proxy karena key pada aplikasi mobile pada akhirnya dapat diekstrak.

## Verifikasi

```bash
flutter analyze
flutter test
```

## Build & distribusi ke Firebase App Distribution (App Tester)

Project ini belum terhubung ke Firebase project manapun — belum ada `google-services.json` atau `.firebaserc`. Distribusi build ke tester dilakukan lewat Firebase CLI langsung terhadap file APK/AAB hasil build Flutter, tanpa perlu menambahkan Firebase SDK ke aplikasi.

### 1. Build APK/AAB untuk tester

```bash
# APK — paling umum untuk install manual & Firebase App Distribution
flutter build apk --release

# atau App Bundle (AAB), jika distribusi lewat Play/Firebase yang mendukung AAB
flutter build appbundle --release
```

Output ada di `build/app/outputs/flutter-apk/app-release.apk` atau `build/app/outputs/bundle/release/app-release.aab`.

Secara default, release build memakai debug signing (bawaan template Flutter) supaya command di atas langsung bisa jalan tanpa setup tambahan — cukup untuk build tester. Untuk build dengan signing production sungguhan:

1. Salin `android/key.properties.example` menjadi `android/key.properties`.
2. Isi `storeFile`, `storePassword`, `keyAlias`, `keyPassword` sesuai keystore kamu (`android/key.properties` sudah di-gitignore, jangan pernah di-commit).
3. Jalankan ulang `flutter build apk --release` — build otomatis memakai signing config release begitu file itu ada.

Package/application ID aplikasi ini adalah `com.heralth.heralth` (lihat `android/app/build.gradle.kts`), pastikan Firebase Android app yang dipakai untuk distribusi terdaftar dengan ID yang sama.

### 2. Autentikasi Firebase CLI

```bash
npm install -g firebase-tools   # sekali saja, jika CLI belum terpasang
firebase login
```

`firebase login` membuka browser untuk login ke akun Google yang punya akses ke Firebase project. Untuk CI/non-interactive, gunakan `firebase login:ci` untuk membuat token, lalu set `FIREBASE_TOKEN` sebagai environment variable di CI dan tambahkan `--token "$FIREBASE_TOKEN"` di command distribusi.

### 3. Upload ke Firebase App Distribution

```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <FIREBASE_ANDROID_APP_ID> \
  --groups "testers" \
  --release-notes "Deskripsi singkat perubahan di build ini"
```

- `<FIREBASE_ANDROID_APP_ID>` didapat dari Firebase Console → Project settings → General → App ID Android (format `1:xxxxxxxxxx:android:xxxxxxxxxxxxxxxx`), atau lewat `firebase apps:list` setelah project terhubung.
- `--groups` merujuk ke tester group yang dibuat di Firebase Console (App Distribution → Testers & Groups).
- Ganti path file ke `.aab` bila mendistribusikan App Bundle.

### Langkah manual yang tersisa

Karena project ini belum punya Firebase project terhubung, sebelum command di atas bisa jalan, developer perlu:

1. Membuat/menghubungkan Firebase project lewat [Firebase Console](https://console.firebase.google.com), lalu mendaftarkan Android app dengan applicationId `com.heralth.heralth`.
2. Menyalin App ID Android dari project tersebut untuk dipakai di flag `--app` pada command distribusi.
3. Menjalankan `firebase login` (atau `firebase login:ci` untuk CI) dengan akun yang punya akses ke project itu.

Langkah-langkah di atas butuh kredensial akun/project spesifik developer sehingga sengaja tidak diotomasi atau di-hardcode di repo ini.
