# 🏪 Jaga Warung – Voice-First POS & OCR

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5-0175C2?style=flat&logo=dart)
![GetX](https://img.shields.io/badge/GetX-4.7-8A2BE2?style=flat)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)

**Solusi Manajemen Warung Pintar dengan Voice Assistant & AI-Powered OCR**

[🎥 Video Demo](#-video-demo) • [✨ Features](#-fitur-utama) • [🚀 Quick Start](#-instalasi) • [📚 Dokumentasi](#-dokumentasi)

</div>

---

## 📖 Tentang Project

**Jaga Warung** adalah aplikasi mobile untuk membantu pemilik warung/UMKM mengelola keuangan, stok, dan utang pelanggan **tanpa perlu mengetik manual**. Cukup bicara atau scan nota belanja, semua transaksi tercatat otomatis!

### 🎯 Problem Statement
- Pemilik warung sibuk melayani pembeli → **tidak sempat mencatat transaksi**
- Menulis manual lambat dan rawan error
- Nota belanja menumpuk, sulit diinput ke sistem

### 💡 Solution
- **Voice Assistant** untuk catat transaksi dengan bicara (seperti Siri/Google Assistant)
- **OCR Nota Belanja** untuk scan dan input otomatis
- **Multi-language TTS** (Indonesia, Jawa, Sunda) untuk aksesibilitas

---

## ✨ Fitur Utama

### 🎤 Voice Agent (AI-Powered)
- Catat transaksi (pemasukan/pengeluaran/utang) dengan **suara**
- Natural Language Processing via **Google Gemini AI**
- Multi-language TTS: **Bahasa Sunda → Jawa → Indonesia** (fallback otomatis)


### 📊 Dashboard Real-time
- Ringkasan harian/mingguan/bulanan (spending, earning, debt)
- Chart transaksi terbaru
- Filtering by period (day/week/month)
- Pull-to-refresh & shimmer loading

### 💳 Manajemen Utang
- Daftar utang per pelanggan
- Voice command untuk catat/bayar utang
- Auto-merge utang dengan nama pelanggan yang sama
- Tandai lunas → otomatis jadi pemasukan

### 📸 OCR Pengeluaran (Smart Scan)
- Scan nota belanja via **Kolosal AI OCR**
- Auto-extract: nominal, nama toko, items
- Edit manual sebelum simpan
- Langsung masuk sebagai `spending` transaction

### 📋 Daftar Transaksi
- List semua transaksi dengan pagination (infinite scroll)
- Filter by type: earning/spending/debts
- Pull-to-refresh
- Currency formatting dengan thousand separator

### 🔐 Authentication
- Login/Register via **Supabase**
- Token management dengan **Flutter Secure Storage**
- Auto-login dengan saved token
- Bearer token untuk semua API calls

---

## 📸 Screenshots

<div align="center">
<table>
  <tr>
    <td align="center"><b>Dashboard</b><br><i>(Voice FAB & Summary)</i></td>
    <td align="center"><b>Voice Assistant</b><br><i>(Listening State)</i></td>
    <td align="center"><b>Manajemen Utang</b><br><i>(Debt List)</i></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/ea32c7b4-91d9-45d9-8d8c-aac49d1645a5" width="250" alt="Dashboard"/></td>
    <td><img src="https://github.com/user-attachments/assets/e2f0149b-d527-4dc0-abf5-e2f40962c917" width="250" alt="Voice"/></td>
    <td><img src="https://github.com/user-attachments/assets/3f037429-e4b0-4007-a6c3-81a6107f93a9" width="250" alt="Debt"/></td>
  </tr>
  <tr>
    <td align="center"><b>OCR Scanner</b><br><i>(Receipt Scan)</i></td>
    <td align="center"><b>Transaksi</b><br><i>(Filter & List)</i></td>
    <td align="center"><b>Login</b><br><i>(Authentication)</i></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/a8e38c6f-ced7-40ad-8bf7-d96ec88c3168" width="250" alt="OCR"/></td>
    <td><img src="https://github.com/user-attachments/assets/fc33a50c-c6fd-4b89-b068-fe22e9a5e8bd" width="250" alt="Transactions"/></td>
    <td><img src="https://github.com/user-attachments/assets/50e37f5d-690d-4f5e-8dd3-6eecb7074764" width="250" alt="Login"/></td>
  </tr>
</table>
</div>



---

## 🛠️ Tech Stack

### Frontend (Mobile)
| Technology | Purpose |
|:-----------|:--------|
| **Flutter 3.24** | Cross-platform mobile framework |
| **Dart 3.5** | Programming language |
| **GetX 4.7** | State management + Dependency Injection + Routing |
| **Dio 5.7** | HTTP client dengan interceptor untuk Bearer token |
| **speech_to_text 7.0** | Speech-to-Text (STT) untuk voice input |
| **flutter_tts 4.2** | Text-to-Speech (TTS) untuk voice feedback |
| **image_picker** | Ambil foto dari camera/gallery untuk OCR |
| **flutter_secure_storage** | Simpan token JWT secara aman |
| **intl** | Format currency & date |
| **shimmer** | Skeleton loading animation |

### Backend & Services
| Service | Purpose |
|:--------|:--------|
| ** API (Express.js)** | Backend untuk transaksi, deployed di **Render** |
| **Supabase** | Authentication (Login/Register) |
| **Google Gemini AI** | Natural Language Processing untuk voice commands |
| **Kolosal AI OCR** | Optical Character Recognition untuk scan nota |

### Architecture
- **Clean Architecture** (separation of concerns)
- **Repository Pattern** (data layer abstraction)
- **Mixin Pattern** (code reuse untuk voice & formatting)
- **Utility Pattern** (helper functions untuk format & transaction types)

---

## 🚀 Instalasi

### Prerequisites
Pastikan sudah terinstall:
- ✅ **Flutter SDK** >= 3.24.0 ([Install Guide](https://docs.flutter.dev/get-started/install))
- ✅ **Dart SDK** >= 3.5.1
- ✅ **Android Studio** (untuk Android) atau **Xcode** (untuk iOS)
- ✅ **Git**

### Step 1: Clone Repository
```bash
git clone https://github.com/Juara-1/jagawarung.git
cd jagawarung
```

### Step 2: Setup Environment Variables
Buat file `.env` di root project:
```bash
# Copy template
cp .env.example .env

# Edit .env dengan API keys kamu
nano .env
```

**Isi `.env`:**
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
GEMINI_API_KEY=your-gemini-api-key
KOLOSAL_API_KEY=your-kolosal-api-key
API_BASE_URL=https://jagawarung-backend.onrender.com
```

> **Cara Dapatkan API Keys:**
> - **Supabase**: https://supabase.com → Create Project → Settings → API
> - **Gemini**: https://aistudio.google.com/app/apikey
> - **Kolosal**: https://kolosal.ai → Dashboard → API Keys

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Run Application

#### Mode Debug (untuk development):
```bash
flutter run
```

#### Build Release APK (untuk production):
```bash
# Build APK
flutter build apk --release

# APK tersimpan di:
# build/app/outputs/flutter-apk/app-release.apk
```

#### Install ke Device:
```bash
# Via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Atau copy APK ke HP dan install manual
```

---

## 📚 Dokumentasi

### Struktur Project
```
lib/
├── app/
│   ├── common/
│   │   ├── mixins/
│   │   │   └── voice_mixin.dart          # STT/TTS logic
│   │   ├── utils/
│   │   │   ├── format_utils.dart         # Currency, date formatting
│   │   │   └── transaction_type_utils.dart # Type helpers
│   │   └── widgets/
│   │       ├── custom_text_field.dart
│   │       └── loading_button.dart
│   ├── core/
│   │   ├── constants.dart                # App-wide constants
│   │   └── theme.dart                    # Custom theme
│   ├── data/
│   │   ├── models/
│   │   │   ├── transaction_model.dart
│   │   │   └── dashboard_summary_model.dart
│   │   ├── providers/
│   │   │   └── real_transaction_provider.dart # API calls
│   │   └── services/
│   │       ├── debt_service.dart
│   │       ├── expense_ocr_service.dart
│   │       └── token_service.dart
│   ├── modules/
│   │   ├── dashboard/
│   │   │   ├── dashboard_view.dart       # Main UI
│   │   │   ├── dashboard_controller.dart # Logic
│   │   │   ├── dashboard_binding.dart    # DI
│   │   │   └── widgets/                  # Extracted widgets
│   │   │       ├── summary_card.dart
│   │   │       ├── transaction_tile.dart
│   │   │       ├── voice_button.dart
│   │   │       └── shimmer_loading.dart
│   │   ├── home/                         # Debt management
│   │   ├── login/
│   │   ├── register/
│   │   ├── smart_restock/                # OCR module
│   │   └── transactions/                 # Transaction list
│   └── routes/
│       ├── app_routes.dart               # Route names
│       └── app_pages.dart                # Route bindings
├── env.dart                              # Environment config
└── main.dart                             # Entry point
```

### API Endpoints

**Base URL:** `https://jagawarung-backend.onrender.com`

| Method | Endpoint | Purpose | Auth |
|:-------|:---------|:--------|:-----|
| `POST` | `/api/agent/transactions` | Voice agent (AI parsing) | ✅ Bearer |
| `POST` | `/api/transactions?upsert=true` | Manual transaction (hutang merge) | ✅ Bearer |
| `POST` | `/api/transactions/{id}/repay` | Pelunasan hutang → pemasukan | ✅ Bearer |
| `GET` | `/api/transactions` | List transaksi (paging, filter) | ✅ Bearer |
| `GET` | `/api/transactions/summary` | Dashboard summary (day/week/month) | ✅ Bearer |
| `DELETE` | `/api/transactions/{id}` | Hapus transaksi | ✅ Bearer |

**Query Parameters untuk `/api/transactions`:**
```
?page=1&per_page=10&type=earning&note=keyword&time_range=week
```

### Voice Commands Examples
```
✅ "Catat pemasukan dua ratus ribu dari penjualan"
✅ "Budi utang seratus ribu"
✅ "Belanja sayur lima puluh ribu"
✅ "Bayar utang Siti lima puluh ribu"
```

---

## 🔊 Voice & Aksesibilitas

### Text-to-Speech (TTS) Fallback
Aplikasi mencoba bahasa secara berurutan:
1. **Bahasa Sunda** (`su-ID`)
2. **Bahasa Jawa** (`jv-ID`)
3. **Bahasa Indonesia** (`id-ID`)
4. **English** (fallback default)

### Voice Button Interaction
- **Tap sekali**: Toggle start/stop listening
- **Long press**: Press to talk, release to stop (ala WhatsApp)
- **Visual feedback**: Pulsing animation saat listening

---

## 🧰 Troubleshooting

### Issue: Mikrofon tidak berfungsi
**Solusi:**
1. Cek permission di Android Settings → Apps → Jaga Warung → Permissions → Microphone ✅
2. Restart aplikasi
3. Pastikan device tidak dalam mode silent/DND

### Issue: 401 Unauthorized
**Solusi:**
1. Pastikan sudah login
2. Token mungkin expired → logout dan login ulang
3. Cek `.env` → `API_BASE_URL` benar

### Issue: 400 Bad Request (debtor_name check)
**Solusi:**
- Sudah di-fix di `TransactionModel.toJson()`
- `debtor_name` hanya dikirim jika `type == TransactionType.debts`
- Update ke versi terbaru

### Issue: OCR return 401 (invalid_scheme)
**Solusi:**
- Sudah di-fix di `ExpenseOcrService`
- API key sekarang pakai `Bearer` token
- Cek `KOLOSAL_API_KEY` di `.env`

### Issue: Android build gagal
**Common Fixes:**
```bash
# 1. Clean project
flutter clean
flutter pub get

# 2. Clean Gradle cache
cd android
./gradlew clean
cd ..

# 3. Rebuild
flutter build apk --release
```

**Build Requirements:**
- compileSdk: 35
- targetSdk: 34
- minSdk: 21
- Gradle: 8.7
- Kotlin: 1.9.24
- Java: 17

---

## 🎥 Video Demo

> **🎬 Tonton Demo Lengkap:** [Link YouTube/Google Drive]

**Durasi:** 3-5 menit  
**Isi Video:**
- Problem statement UMKM/warung
- Solusi voice-first & OCR
- Demo fitur unggulan:
  - Voice input transaksi
  - OCR scan nota
  - Dashboard real-time
  - Manajemen utang
- Impact & future roadmap

---

## 🤝 Kontribusi

Contributions are welcome! Silakan:
1. Fork repo ini
2. Buat branch baru (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push ke branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

**Coding Guidelines:**
- Indentasi: 2 spaces
- Naming: camelCase
- Comment: hanya untuk logic kompleks
- Prioritas: Dart/Flutter best practices

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 👥 Team

**Built with ❤️ by Juara 1 Hackathon IMPHNEN**

- **Developer:** Arvan Yudhistia Ardana & Daffa Alexander
- **Contact:** [arvanardana1@gmail.com]
- **Repository:** [https://github.com/Juara-1/jagawarung](JAGA WARUNG)

---

## 🔮 Future Roadmap

- [ ] CI/CD pipeline dengan GitHub Actions
- [ ] Deploy to Google Play Store
- [ ] iOS version
- [ ] Offline mode dengan local database (SQLite/Hive)
- [ ] Multi-store support (untuk owner dengan banyak cabang)
- [ ] Laporan keuangan PDF export
- [ ] WhatsApp integration untuk reminder utang
- [ ] Barcode scanner untuk stok barang

---

<div align="center">

**⭐ Jangan lupa kasih star kalo project ini membantu! ⭐**

Made with Flutter 💙 | Voice-First 🎤

</div>
