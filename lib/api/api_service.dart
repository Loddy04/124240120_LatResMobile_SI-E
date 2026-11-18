// =============================================================
// API SERVICE (Modul V - "Class dengan Static Method")
// =============================================================
// Soal mewajibkan: kode fetch & parse API berada di FILE TERPISAH.
// Semua komunikasi ke API dikumpulkan di sini, sehingga halaman (screen)
// cukup memanggil ApiService.getGames() tanpa tahu detail http-nya.
//
// "static" artinya method bisa dipanggil langsung lewat nama class
// (ApiService.getGames()) tanpa perlu membuat object (ApiService()).
import 'dart:convert'; // untuk jsonDecode
import 'package:http/http.dart' as http;

import '../models/game.dart';

class ApiService {
  static const String baseUrl = 'https://www.freetogame.com/api';

  // ---------------------------------------------------------
  // 1. Ambil SEMUA game -> GET https://www.freetogame.com/api/games
  // ---------------------------------------------------------
  // Future<...> = hasilnya baru ada "nanti" (menunggu internet),
  // maka harus dipanggil dengan await di dalam fungsi async.
  static Future<List<Game>> getGames() async {
    final response = await http.get(Uri.parse('$baseUrl/games'));

    // statusCode 200 = request berhasil
    if (response.statusCode == 200) {
      // PERHATIKAN BENTUK JSON-NYA!
      // API ini langsung mengembalikan ARRAY: [ {...}, {...} ]
      // (beda dengan API lain yang dibungkus object, misal {"results": [...]}
      //  -> kalau begitu, ambil dulu: data['results'])
      final List<dynamic> data = jsonDecode(response.body);

      // Ubah setiap Map di dalam list menjadi object Game
      return data.map((json) => Game.fromJson(json)).toList();
    } else {
      // throw -> lempar error, nanti ditangkap oleh try-catch di screen
      throw Exception('Gagal memuat daftar game');
    }
  }

  // ---------------------------------------------------------
  // 2. Ambil DETAIL satu game -> GET .../api/game?id={id}
  // ---------------------------------------------------------
  // Perhatikan: detail memakai QUERY PARAMETER (?id=452),
  // bukan path (/game/452). Ikuti persis format dari soal.
  static Future<Game> getGameDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/game?id=$id'));

    if (response.statusCode == 200) {
      // Detail mengembalikan SATU object: { ... }
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Game.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail game');
    }
  }
}
