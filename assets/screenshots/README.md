# Screenshots Folder

Folder ini untuk menyimpan screenshots aplikasi yang akan ditampilkan di README utama.

## Checklist Screenshots Yang Dibutuhkan:

- [ ] **dashboard.png** - Dashboard dengan ringkasan keuangan dan voice button
- [ ] **voice.png** - Voice assistant dalam state listening (dengan animasi)
- [ ] **debt.png** - Halaman manajemen utang (daftar pelanggan yang berutang)
- [ ] **ocr.png** - OCR scanner atau reconciliation page
- [ ] **transactions.png** - List semua transaksi dengan filter
- [ ] **login.png** - Halaman login/register

## Cara Ambil Screenshots:

### Android:
1. Build release APK: `flutter build apk --release`
2. Install ke device: `adb install build/app/outputs/flutter-apk/app-release.apk`
3. Buka aplikasi dan navigasi ke setiap halaman
4. Ambil screenshot:
   - **Tekan Volume Down + Power** secara bersamaan
   - Atau gunakan `adb shell screencap -p /sdcard/screenshot.png` kemudian `adb pull /sdcard/screenshot.png`

### Emulator:
1. Jalankan aplikasi di emulator
2. Klik icon camera di toolbar emulator (atau Ctrl+S / Cmd+S)
3. Save screenshot

## Tips untuk Screenshot Berkualitas:

✅ **DO:**
- Gunakan data yang realistis (bukan "Test" atau "Lorem Ipsum")
- Pastikan UI dalam kondisi loaded (tidak loading skeleton)
- Ambil di kondisi best case (tidak ada error state)
- Gunakan device/emulator dengan resolusi bagus (min 1080x1920)
- Light mode untuk clarity

❌ **DON'T:**
- Jangan ada data sensitif (nama asli, nomor HP, dll)
- Jangan ada error/debug messages
- Jangan blur atau low quality
- Jangan ada watermark

## Recommended Tools:

- **Android:** Built-in screenshot atau [scrcpy](https://github.com/Genymobile/scrcpy)
- **Edit/Crop:** [Figma](https://figma.com), [GIMP](https://www.gimp.org/), atau online tools
- **Compress:** [TinyPNG](https://tinypng.com/) untuk reduce file size tanpa quality loss

## Screenshot Dimensions:

Target width: **1080px** (akan di-resize jadi 250px di README, tapi keep high-res untuk quality)

---

Setelah screenshots siap, update path di `README.md` sesuai nama file yang sudah diupload.

