# Jaga Warung 🏪 – Voice-First POS & OCR

**Jaga Warung** adalah aplikasi manajemen warung pintar berbasis Flutter yang dirancang untuk membantu pemilik warung (UMKM) dalam mencatat hutang pelanggan dan mengelola stok barang (restock) secara efisien menggunakan teknologi AI.

## ✨ Fitur Utama (current)
- **Voice Agent Transaksi**: tombol mic ala Siri/Assistant, kirim ke backend `/api/agent/transactions` untuk `earning`, `spending`, `debts` (hutang pakai upsert). TTS fallback bahasa: Sunda → Jawa → Indonesia.
- **Dashboard**: ringkasan pemasukan/pengeluaran/utang harian, list transaksi terbaru, mic dengan animasi pulsa.
- **Manajemen Utang**: daftar per pelanggan, catat via voice agent, hapus, tandai lunas (`POST /api/transactions/{id}/repay` → auto jadi pemasukan).
- **Daftar Semua Transaksi**: halaman list dengan paging, filter tipe (earning/spending/debts), infinite scroll.
- **OCR Pengeluaran**: scan nota belanja via Kolosal AI, edit nominal, simpan sebagai `spending`.
- **Auth & Token**: login Supabase, token disimpan di Flutter Secure Storage dan dikirim sebagai Bearer ke backend.

## 🛠️ Teknologi
- Flutter 3 / Dart, GetX (state + DI + routing), Clean Architecture.
- HTTP: Dio + interceptor Bearer token.
- Speech: `speech_to_text` (STT), `flutter_tts` (TTS).
- AI: Gemini (parsing perintah suara), Kolosal OCR (nota belanja).
- Backend: custom API (Render) untuk transaksi + Supabase untuk auth.

## ⚙️ Environment
Buat file `.env` di root (lihat `env.dart`):
```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
GEMINI_API_KEY=...
KOLOSAL_API_KEY=...
API_BASE_URL=https://jagawarung-backend.onrender.com
```

## 🚀 Menjalankan
```bash
flutter pub get
flutter run
```

## 🔌 Endpoint Penting
- `POST /api/agent/transactions` — voice agent (prompt + type).
- `POST /api/transactions?upsert=true` — hutang (merge by debtor).
- `POST /api/transactions/{id}/repay` — pelunasan hutang → pemasukan.
- `GET /api/transactions` — list transaksi (paging, filter type/note/time).
- `GET /api/transactions/summary?time_range=day|week|month` — ringkasan.

## 🧭 Navigasi Utama
- Dashboard (ringkasan + mic).
- Utang (daftar per pelanggan + mic).
- Transaksi (list semua, filter/paging).
- Smart Restock/OCR (scan nota → pengeluaran).

## 🔊 Voice & Aksesibilitas
- TTS mencoba `su-ID` → `jv-ID` → `id-ID` → fallback default.
- Mic button: tap untuk toggle, long-press juga didukung.
- Status TTS dan error ditampilkan via snackbar.

## 🧰 Troubleshooting Singkat
- Mic tidak jalan: cek izin mikrofon, lalu restart app.
- 401/unauthorized: pastikan sudah login, token tersimpan (Flutter Secure Storage).
- 400 debtor_name check: untuk `earning/spending` jangan kirim debtor_name (sudah di-handle di model).
- OCR 401: pastikan Kolosal API key format Bearer.

## 📂 Struktur Singkat
- `lib/app/data` — models, providers (RealTransactionProvider), services (Token, Debt, OCR, AI parsing).
- `lib/app/modules` — halaman & controller GetX (dashboard, home/utang, transactions, smart_restock).
- `lib/app/routes` — route definitions.
- `lib/main.dart` — init, env load, Supabase auth, auto-login token.

## 🤝 Kontribusi
PR / issue dipersilakan. Jaga konsistensi: 2 spaces, camelCase, komentar hanya untuk logika non-trivial.