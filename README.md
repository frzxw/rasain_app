# Pemrograman Visual dan Piranti Bergerak

---

## Tugas 3

---

### Kelompok 24 Kelas Kamis

Proyek ini dikembangkan oleh kelompok 24 sebagai bagian dari tugas 3 pada mata kuliah Pemrograman Visual dan Piranti Bergerak. Adapun anggota dari kelompok kami adalah:

- 2305995 A Bintang Iftitah FJ
- 2307589 Fariz Wibisono
- 2308817 Hafidz Tantowi
- 2309245 Hasbi Haqqul Fikri
- 2308163 Putra Hadiyanto Nugroho


---

## Deskripsi Aplikasi

---

Aplikasi **Rasain** adalah aplikasi berbasis Flutter yang menampilkan berbagai resep masakan Indonesia dengan detail lengkap. Aplikasi ini dirancang dengan pendekatan dwibahasa, menggunakan kode Bahasa Inggris untuk kolaborasi pengembang global sambil menampilkan konten kuliner dalam Bahasa Indonesia.

## Fitur Utama

---

- **Eksplorasi Resep** – Jelajahi koleksi resep masakan Indonesia yang beragam.  
- **Detail Resep** – Informasi lengkap tentang bahan, instruksi memasak, dan waktu persiapan.  
- **Pencarian Cerdas** – Cari resep berdasarkan nama atau bahan.  
- **Pencarian Gambar** – Temukan resep dengan mengunggah foto makanan.  
- **Asisten Koki Virtual** – Dapatkan tips memasak, alternatif bahan, dan panduan langkah demi langkah.  
- **Komunitas** – Bagikan pengalaman memasak dan terhubung dengan penggemar masakan lainnya.  
- **Manajemen Dapur** – Kelola bahan yang Anda miliki dan dapatkan saran resep sesuai inventaris.  
- **Profil Pengguna** – Simpan resep favorit dan pantau perjalanan memasak Anda.

## Teknologi yang Digunakan

---

- **Flutter** (versi 3.29.3)
- **Dart**
- **State Management:** Provider
- **Navigation:** GoRouter
- **UI Components:** Material Design

## Cara Install dan Menjalankan Aplikasi

---

### **Clone Repository**

```bash
git clone https://github.com/frzxw/rasain_app.git
cd rasain_app
```

### **Install Dependencies**

Pastikan Anda telah menginstal Flutter versi terbaru. Jika belum, unduh Flutter dari [situs resmi](https://flutter.dev/docs/get-started/install). Setelah itu, jalankan perintah berikut:

```bash
flutter pub get
```

### **Menjalankan Aplikasi**

Jalankan aplikasi di emulator atau perangkat fisik dengan perintah berikut:

```bash
flutter run
```

## Struktur Folder

---

```
lib/
├── main.dart             # Entry point aplikasi
├── app.dart              # Konfigurasi aplikasi utama
├── routes.dart           # Rute navigasi
├── core/                 # Komponen utama
│   ├── constants/        # Konstanta aplikasi
│   ├── theme/            # Definisi tema UI
│   └── widgets/          # Widget bersama
├── features/             # Fitur aplikasi
│   ├── home/             # Layar beranda 
│   ├── recipe_detail/    # Detail resep
│   ├── community/        # Forum komunitas
│   ├── chat/             # Asisten koki virtual
│   ├── profile/          # Profil pengguna
│   └── pantry/           # Manajemen dapur
├── models/               # Model data
└── services/             # Layanan dan handler API
```