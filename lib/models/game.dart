// =============================================================
// MODEL DATA GAME DARI API (Modul V - "Menggunakan Model")
// =============================================================
// Class ini merepresentasikan SATU game dari API FreeToGame.
//
// API yang dipakai:
//   List   : https://www.freetogame.com/api/games
//   Detail : https://www.freetogame.com/api/game?id={id}
//
// Contoh JSON (dari endpoint DETAIL):
// {
//   "id": 452,
//   "title": "Call of Duty: Warzone",
//   "thumbnail": "https://www.freetogame.com/g/452/thumbnail.jpg",
//   "short_description": "A standalone free-to-play battle royale ...",
//   "description": "Call of Duty: Warzone is both a standalone ...",
//   "genre": "Shooter",
//   "platform": "Windows",
//   "publisher": "Activision",
//   "developer": "Infinity Ward",
//   "release_date": "2020-03-10",
//   "screenshots": [
//     {"id": 1124, "image": "https://.../Call-of-Duty-Warzone-1.jpg"},
//     {"id": 1125, "image": "https://.../Call-of-Duty-Warzone-2.jpg"}
//   ]
// }
//
// PENTING: endpoint LIST tidak punya "description" & "screenshots"
// (hanya ada di DETAIL). Karena itu kedua field tersebut diberi nilai
// cadangan (?? '' dan list kosong) supaya fromJson tidak error saat
// dipakai untuk data list.
//
// TIPS RESPONSI: selalu buka endpoint di browser dulu, lihat nama key-nya
// (huruf besar/kecil & underscore harus PERSIS sama, contoh "release_date").
class Game {
  final int id;
  final String title;
  final String thumbnail;
  final String shortDescription;
  final String description;
  final String genre;
  final String platform;
  final String publisher;
  final String developer;
  final String releaseDate;
  final List<String> screenshots; // hanya berisi URL gambarnya saja

  Game({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.shortDescription,
    required this.description,
    required this.genre,
    required this.platform,
    required this.publisher,
    required this.developer,
    required this.releaseDate,
    required this.screenshots,
  });

  // factory constructor: mengubah Map JSON -> object Game.
  // "??" = kalau nilainya null, pakai nilai di kanannya (anti crash).
  factory Game.fromJson(Map<String, dynamic> json) {
    // ---- Cara mengambil data dari LIST OF OBJECT di JSON ----
    // "screenshots" bentuknya: [ {"id":.., "image":".."}, {...} ]
    // 1. Ambil sebagai List (kalau tidak ada -> list kosong [])
    // 2. map: dari setiap object, ambil key "image"-nya saja
    // 3. toList: jadikan List<String>
    final List<dynamic> rawScreenshots = json['screenshots'] ?? [];
    final List<String> screenshotUrls = rawScreenshots
        .map((s) => s['image'].toString())
        .toList();

    return Game(
      id: json['id'],
      title: json['title'] ?? '-',
      thumbnail: json['thumbnail'] ?? '',
      shortDescription: json['short_description'] ?? '',
      description: json['description'] ?? '',
      genre: json['genre'] ?? '-',
      platform: json['platform'] ?? '-',
      publisher: json['publisher'] ?? '-',
      developer: json['developer'] ?? '-',
      releaseDate: json['release_date'] ?? '-',
      screenshots: screenshotUrls,
    );
  }
}
