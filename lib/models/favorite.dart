// =============================================================
// MODEL FAVORITE UNTUK HIVE (Modul VI)
// =============================================================
// Menyimpan data yang difavoritkan user ke database lokal Hive,
// supaya favorit TIDAK HILANG walau aplikasi ditutup.
//
// News, blog, dan report disimpan dalam SATU box ('favorites').
// Karena itu kita juga menyimpan "menu"-nya (articles / blogs / reports),
// supaya saat item favorit diklik, halaman detail tahu harus memanggil
// endpoint yang mana.
//
// APA SAJA YANG DISIMPAN?
//   Cukup data yang DITAMPILKAN di halaman favorit (judul, author, gambar)
//   + id (untuk membuka detail lagi). Detail lengkap tetap diambil dari API.
//
// SAAT RESPONSI:
//   1. Cari [UBAH-FAV-1], sesuaikan field dengan yang ditampilkan di
//      halaman favorit soalmu.
//   2. Jalankan build_runner lagi (lihat langkah di user.dart).
//   3. Jika soal tidak punya "menu" (hanya 1 jenis data), field `menu`
//      boleh dihapus dan makeKey cukup memakai id.
import 'package:hive/hive.dart';

part 'favorite.g.dart';

// typeId 1, karena 0 sudah dipakai oleh User. HARUS BERBEDA.
@HiveType(typeId: 1)
class Favorite extends HiveObject {
  // 🔧 [UBAH-FAV-1] DAFTAR FIELD YANG DISIMPAN
  // Setiap field diberi nomor @HiveField berurutan (0, 1, 2, ...).
  @HiveField(0)
  final String menu; // 'articles', 'blogs', atau 'reports'

  @HiveField(1)
  final int itemId; // id data di API (untuk membuka detail lagi)

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String author;

  @HiveField(4)
  final String imageUrl;

  Favorite({
    required this.menu,
    required this.itemId,
    required this.title,
    required this.author,
    required this.imageUrl,
  });

  // KEY UNIK untuk menyimpan di box, contoh: "articles_40887".
  //
  // Kenapa butuh key buatan sendiri?
  //  - box.put(key, data) -> menyimpan dengan key pilihan kita.
  //    Nanti mudah dicek (containsKey) dan dihapus (delete) pakai key itu.
  //  - box.add(data)      -> key otomatis 0, 1, 2, ... dan data yang sama
  //    bisa tersimpan DOBEL.
  //
  // Kenapa digabung dengan menu? Id news dan id blog bisa sama (misal
  // keduanya punya id 100), jadi digabung supaya tidak saling menimpa.
  //
  // "static" = dipanggil lewat nama class: Favorite.makeKey('articles', 1)
  static String makeKey(String menu, int id) => '${menu}_$id';
}
