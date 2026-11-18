// =============================================================
// MODEL FAVORITE UNTUK HIVE (Modul VI)
// =============================================================
// Menyimpan data yang difavoritkan user, baik itu news, blog, maupun report.
// Karena ketiganya disimpan dalam satu box, kita simpan juga "menu"-nya
// (articles / blogs / reports) supaya saat dibuka lagi kita tahu
// endpoint mana yang harus dipanggil di halaman detail.
import 'package:hive/hive.dart';

part 'favorite.g.dart';

@HiveType(typeId: 1)
class Favorite extends HiveObject {
  @HiveField(0)
  final String menu; // 'articles', 'blogs', atau 'reports'

  @HiveField(1)
  final int itemId; // id data di API

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

  // Key unik untuk menyimpan di box, contoh: "articles_40887".
  // Id news dan id blog bisa sama, jadi key-nya digabung dengan nama menu
  // supaya tidak saling menimpa.
  static String makeKey(String menu, int id) => '${menu}_$id';
}
