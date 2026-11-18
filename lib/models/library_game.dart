// =============================================================
// MODEL LIBRARY UNTUK HIVE (Modul VI)
// =============================================================
// Menyimpan game yang sudah di-"Get" user ke database lokal Hive.
//
// Kenapa tidak langsung menyimpan class Game?
// -> Library hanya butuh data yang ditampilkan di list (thumbnail,
//    nama, genre, platform). Detail lengkapnya tetap diambil dari API
//    saat item diklik, jadi data yang disimpan lebih kecil & sederhana.
//
// LANGKAH MEMBUAT MODEL HIVE (hafalkan urutannya!):
// 1. import 'package:hive/hive.dart';
// 2. tulis: part 'nama_file.g.dart';
// 3. beri anotasi @HiveType(typeId: X) pada class, extends HiveObject
// 4. beri @HiveField(0), @HiveField(1), ... pada setiap atribut
// 5. jalankan di terminal:
//      dart run build_runner build --delete-conflicting-outputs
// 6. file library_game.g.dart (berisi LibraryGameAdapter) akan terbuat
// 7. daftarkan adapter di main.dart: Hive.registerAdapter(LibraryGameAdapter());
import 'package:hive/hive.dart';

part 'library_game.g.dart';

// typeId: identitas class di Hive. Kalau ada beberapa model Hive,
// masing-masing WAJIB beda (0, 1, 2, ...). Jangan diubah setelah ada data.
@HiveType(typeId: 0)
class LibraryGame extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String thumbnail;

  @HiveField(3)
  final String genre;

  @HiveField(4)
  final String platform;

  LibraryGame({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.genre,
    required this.platform,
  });
}
