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
