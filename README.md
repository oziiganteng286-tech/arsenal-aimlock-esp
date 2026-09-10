# ⚡ SkyZen Arsenal Aim Lock + ESP

Premium Roblox Arsenal Script dengan UI Cyberpunk Style

## 🚀 Quick Start

Salin dan paste code ini di script executor Anda:

```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/oziiganteng286-tech/arsenal-aimlock-esp/main/arsenal-aimlock-esp.lua'))()
```

## ✨ Fitur Utama

### 🎯 Aim Lock
- **Target Part Selection**: Pilih antara Head, Body, atau Hand
- **Smooth Aiming**: Pergerakan camera yang smooth
- **Auto Target**: Otomatis mengunci ke pemain terdekat
- **Customizable**: Atur smoothness dan jarak maksimal

### 👁️ ESP
- **Player Box**: Kotak outline pemain
- **Player Names**: Tampilkan nama pemain
- **Glow Effect**: Visual yang menarik dengan efek glow
- **Toggle On/Off**: Nyalah matikan dengan mudah

## 🎮 Cara Penggunaan

### GUI Controls
1. **AIM LOCK Card**
   - Klik tombol "TURN ON/OFF" untuk mengaktifkan
   - Pilih target part: Head, Body, atau Hand
   - Perubahan akan langsung teraplikasi

2. **ESP Card**
   - Klik tombol "TURN ON/OFF" untuk mengaktifkan ESP
   - Saat OFF, semua ESP akan hilang

### Keyboard Shortcuts
- **Press E**: Toggle Aim Lock ON/OFF
- **Press R**: Toggle ESP ON/OFF

## ⚙️ Konfigurasi

Edit bagian `Config` di script untuk customize:

```lua
local Config = {
    AimLockEnabled = false,      -- Default status aim lock
    ESPEnabled = true,            -- Default status ESP
    TargetPart = "Head",          -- Head, Torso, RightHand
    MaxDistance = 500,            -- Jarak maksimal dalam studs
    Smoothness = 0.1,             -- Smoothness aiming (0.05-0.3)
    AimKey = Enum.KeyCode.E,      -- Tombol toggle aim lock
    ESPKey = Enum.KeyCode.R,      -- Tombol toggle ESP
}
```

## 🎨 UI Design

- **Header**: Status online dan info script
- **Sidebar**: Menu navigasi
- **Main Content**: Settings untuk Aim Lock dan ESP
- **Color Scheme**: Cyberpunk blue dengan neon accents

### Warna
```
Primary Cyan: RGB(0, 170, 255)
Light Cyan: RGB(80, 215, 255)
Success Green: RGB(0, 255, 136)
Error Red: RGB(255, 85, 105)
Background: RGB(10, 15, 30)
```

## 📋 Requirements

- Script Executor (Synapse X, Script-Ware, KRNL, etc)
- Roblox Game dengan sistem senjata (Arsenal, Counter Blox, dll)
- Stabilitas koneksi internet

## ⚠️ Disclaimer

Script ini dibuat untuk tujuan edukatif. Penggunaan pada game online dapat menghasilkan:
- Ban akun
- Suspension dari game
- Tindakan dari developer

Gunakan dengan bijak dan atas tanggung jawab Anda sendiri.

## 📝 Changelog

### v1.0.0 (Current)
- ✅ Aim Lock dengan pilihan target part
- ✅ ESP toggle
- ✅ Premium SkyZen UI
- ✅ Keyboard shortcuts
- ✅ Smooth aiming system

## 🤝 Support

Jika ada bug atau fitur request, silakan buat issue atau hubungi developer.

## 👨‍💻 Author

**SkyZen** - Arsenal Script Hub

---

**Status**: 🟢 Online & Active

Made with ❤️ for the Roblox community
