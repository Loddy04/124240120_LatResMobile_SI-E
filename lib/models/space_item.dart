// =============================================================
// MODEL DATA DARI API (Modul V - bagian "Menggunakan Model")
// =============================================================
// APA ITU MODEL?
//   Model adalah "cetakan" untuk satu data. Di sini, satu SpaceItem
//   = satu berita / blog / report.
//
// KENAPA PERLU MODEL?
//   Tanpa model, data dari API berupa Map dan diakses dengan:
//       item['title']     <- kalau salah ketik ('titel'), TIDAK ketahuan
//                            sampai aplikasi crash saat dijalankan
//   Dengan model, diakses dengan:
//       item.title        <- kalau salah ketik, langsung merah di editor
//
// TUGAS UTAMA MODEL = fromJson:
//   menerjemahkan NAMA KEY di JSON  ->  NAMA VARIABEL di Dart
//
//   Contoh JSON satu berita dari API:
//   {
//     "id": 40887,
//     "title": "PLD Space Investor Selects ...",
//     "news_site": "European Spaceflight",
//     "image_url": "https://.../gambar.webp",
//     "url": "https://europeanspaceflight.com/...",
//     "summary": "Japanese satellite manufacturer ...",
//     "published_at": "2026-11-18T07:25:17Z"
//   }
//
// SAAT RESPONSI (API berbeda):
//   1. Salin file ini, ganti nama file & nama class (Ctrl+H: SpaceItem -> NamaBaru)
//   2. Cari tanda [UBAH-MODEL-1], [UBAH-MODEL-2], [UBAH-MODEL-3] lalu sesuaikan
class SpaceItem {
  // 🔧 [UBAH-MODEL-1] DAFTAR FIELD
  // Tulis semua data yang dibutuhkan halaman list & detail.
  // "final" = nilainya tidak berubah setelah object dibuat.
  // Nama variabel BEBAS (pakai camelCase), tidak harus sama dengan JSON.
  final int id; // id unik, dipakai untuk membuka detail
  final String title;
  final String author; // diambil dari "news_site" (lihat fromJson)
  final String imageUrl;
  final String url; // link ke situs resmi berita
  final String summary;
  final String publishedAt;

  // 🔧 [UBAH-MODEL-2] CONSTRUCTOR
  // Isinya harus SAMA dengan daftar field di atas.
  // "required" = wajib diisi saat membuat object.
  SpaceItem({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.url,
    required this.summary,
    required this.publishedAt,
  });

  // 🔧 [UBAH-MODEL-3] fromJson
  // "factory" = constructor khusus yang membuat object dari data lain
  // (di sini dari Map JSON).
  //
  // Format setiap baris:
  //   namaVariabel: json['nama_key_di_json'] ?? nilaiCadangan,
  //                       ^^^^^^^^^^^^^^^^
  //                       HARUS PERSIS seperti di browser
  //                       (huruf besar/kecil & underscore)
  //
  // "??" artinya: kalau nilai di kiri null (kosong), pakai nilai di kanan.
  // Ini mencegah crash jika ada data yang tidak punya field tersebut.
  //
  // Jika nilai di JSON berupa object { }, masuk 2 tingkat:
  //   json['origin']['name']
  factory SpaceItem.fromJson(Map<String, dynamic> json) {
    return SpaceItem(
      id: json['id'],
      title: json['title'] ?? '-',
      // Di contoh soal, author yang tampil adalah "NASA", "Spaceflight Now",
      // dll. Nilai tersebut ada di key "news_site", jadi itu yang dipakai
      // sebagai author (sekaligus dasar fitur filter).
      author: json['news_site'] ?? 'Unknown',
      imageUrl: json['image_url'] ?? '',
      url: json['url'] ?? '',
      summary: json['summary'] ?? '',
      publishedAt: json['published_at'] ?? '',
    );
  }
}
