# Belajarku

**Belajarku** adalah aplikasi manajemen jadwal pribadi yang intuitif dan kaya fitur, dirancang untuk membantu pengguna mengatur tugas, memantau jadwal belajar atau kerja, serta melacak progres dengan mudah. Aplikasi ini menawarkan antarmuka yang bersih, fungsionalitas kuat, dan pengalaman pengguna yang dapat dikustomisasi dengan pengaturan tema.

## Fitur Utama

- **Manajemen Tugas Lengkap**  
  Tambah, edit, hapus, dan tandai tugas utama sebagai selesai, lengkap dengan judul, deskripsi, tanggal, waktu, kategori, dan subtugas. Tugas disortir secara otomatis dan dapat dicari.

- **Kalender Jadwal Interaktif**  
  Visualisasi tugas dalam tampilan kalender dengan indikator tanggal untuk tugas yang dijadwalkan.

- **Ringkasan Notifikasi**  
  Lihat ringkasan cepat untuk tugas hari ini, tugas yang melewati tenggat, dan tugas yang sudah selesai.

- **Statistik Produktivitas**  
  Lacak produktivitas melalui statistik tugas selesai/belum selesai serta grafik mingguan penyelesaian tugas.

- **Splash Screen Animasi**  
  Animasi transisi saat aplikasi diluncurkan dengan latar putih, logo bergerak dari bawah ke tengah, dan teks yang muncul perlahan.

- **Pengaturan Tema Dinamis**  
  Ubah antara mode gelap dan terang dengan animasi transisi. Preferensi tema akan disimpan secara otomatis.

## Teknologi yang Digunakan

- Flutter – Framework UI lintas platform
- Hive – Database NoSQL ringan untuk penyimpanan lokal
- Provider – Manajemen state yang sederhana dan efisien
- Google Fonts – Tipografi khusus (Poppins)
- Table Calendar – Komponen kalender fleksibel
- FL Chart – Visualisasi data dalam bentuk grafik
- UUID – Untuk membuat ID unik
- Intl – Format tanggal dan waktu yang terlokalisasi

## Memulai Proyek

Ikuti langkah-langkah berikut untuk menjalankan proyek secara lokal di perangkat Anda.

### Persiapan

Pastikan Anda telah menginstal:

- Flutter SDK  
- Dart SDK  
- IDE pilihan (VS Code dengan Flutter extension, Android Studio, dll.)

### Instalasi

```bash
# Kloning repositori
git clone https://github.com/nblnutinside/BelajarKu.git
cd belajarku

# Ambil semua dependency
flutter pub get

# Generate file adapter Hive
flutter packages pub run build_runner build --delete-conflicting-outputs
# Jika gagal, gunakan:
dart run build_runner build --delete-conflicting-outputs
#it work everytime hehehe
