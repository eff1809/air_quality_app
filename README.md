# Air Quality App

Aplikasi Flutter untuk mengecek indeks kualitas udara (AQI) berdasarkan nama kota.
Dibuat untuk tugas Evaluasi Pembelajaran Pemrograman Mobile.

**Nama:** Efraim Imanuel Parasak
**NIM:** D121241062
**Program Studi:** Teknik Informatika, Universitas Hasanuddin

## Fitur
- Mengambil data AQI real-time dari REST API WAQI (World Air Quality Index)
- Menampilkan AQI, kategori, polutan dominan, PM2.5, dan waktu pembaruan
- Tiga kondisi layar dengan `FutureBuilder`: Loading, Success, dan Error
- Menyimpan kota terakhir yang dicari dan riwayat 5 pencarian terakhir (SharedPreferences)
- Warna kartu mengikuti kategori AQI

## Pemenuhan Kriteria Tugas
| Kriteria | Implementasi |
|---|---|
| REST API | `http` memanggil WAQI (`lib/services/aqi_service.dart`) |
| Asynchronous UI | `FutureBuilder` dengan state Loading, Success, Error (`lib/screens/home_screen.dart`) |
| Local Storage | `shared_preferences` untuk kota terakhir dan riwayat (`lib/services/storage_service.dart`) |

## Teknologi
- Flutter (Dart)
- Paket: `http`, `shared_preferences`
- API: [WAQI](https://aqicn.org/api/)

## Struktur Proyek
lib/
├── config/ # konfigurasi API key
├── models/ # model data AirQuality
├── services/ # REST API dan penyimpanan lokal
├── screens/ # tampilan utama
└── main.dart


## Cara Menjalankan
1. Clone repositori:
   ```bash
   git clone https://github.com/USERNAME/air_quality_app.git
   cd air_quality_app
   ```
2. Daftar token gratis di https://aqicn.org/data-platform/token
3. Salin `lib/config/api_config.example.dart` menjadi `lib/config/api_config.dart`, lalu isi token:
   ```dart
   class ApiConfig {
     static const String waqiToken = 'TOKEN_KAMU';
   }
   ```
4. Instal dependensi dan jalankan:
   ```bash
   flutter pub get
   flutter run
   ```

## Tangkapan Layar
| Loading | Success | Error | Riwayat |
|---|---|---|---|
| ![Loading](docs/screenshots/02-loading.png) | ![Success](docs/screenshots/03-success.png) | ![Error](docs/screenshots/04-error.png) | ![Riwayat](docs/screenshots/05-riwayat.png) |

## Catatan
- Tidak semua kota memiliki stasiun pemantau di WAQI. Kota yang tidak tersedia akan menampilkan pesan error.
- File `api_config.dart` tidak disertakan di repositori demi keamanan API key.