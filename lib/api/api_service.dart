// =============================================================
// API SERVICE (Modul V - Static Method)
// =============================================================
// Semua request ke API Rick and Morty dikumpulkan di sini.
//
// Endpoint dari soal:
//   List karakter   : /character
//   Detail karakter : /character/{id}
//   Filter status   : /character?status=alive | dead | unknown
//   (bonus) Cari    : /character?name=rick
//   Episode         : /episode
//
// Query parameter bisa DIGABUNG dengan "&":
//   /character?name=rick&status=alive
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/character.dart';
import '../models/episode.dart';

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  // ---------------------------------------------------------
  // LIST KARAKTER (+ filter status & pencarian nama)
  // ---------------------------------------------------------
  // Parameter opsional ({...}) boleh tidak diisi:
  //   ApiService.getCharacters()                       -> semua
  //   ApiService.getCharacters(status: 'alive')        -> filter
  //   ApiService.getCharacters(name: 'rick', status: 'dead')
  static Future<List<Character>> getCharacters({
    String? status,
    String? name,
  }) async {
    // Susun query parameter dalam Map, lalu Uri yang merangkainya.
    // Cara ini lebih aman daripada menyambung string manual, karena
    // spasi/karakter khusus pada nama otomatis di-encode (misal "Morty Smith").
    final Map<String, String> query = {};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (name != null && name.isNotEmpty) query['name'] = name;

    final uri = Uri.parse('$baseUrl/character').replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Bentuk respons: {"info": {...}, "results": [ ... ]}
      // -> list karakternya ada di key "results"
      final List<dynamic> results = data['results'];
      return results.map((json) => Character.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // KHUSUS API INI: jika pencarian/filter tidak menemukan apa pun,
      // API membalas 404 {"error": "There is nothing here"}.
      // Itu bukan error koneksi, jadi kembalikan list kosong saja.
      return [];
    } else {
      throw Exception('Gagal memuat karakter');
    }
  }

  // ---------------------------------------------------------
  // DETAIL KARAKTER -> /character/{id}
  // ---------------------------------------------------------
  static Future<Character> getCharacterDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/character/$id'));

    if (response.statusCode == 200) {
      // Detail langsung berupa SATU object (tanpa "results")
      return Character.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat detail karakter');
    }
  }

  // ---------------------------------------------------------
  // SEMUA EPISODE (dengan PAGINATION)
  // ---------------------------------------------------------
  // API hanya memberi 20 data per halaman. Respons-nya:
  //   {"info": {"next": "https://.../episode?page=2", ...}, "results": [...]}
  // "next" berisi URL halaman berikutnya, dan bernilai null di halaman
  // terakhir. Jadi kita ulangi request selama "next" tidak null.
  static Future<List<Episode>> getEpisodes() async {
    final List<Episode> episodes = [];
    String? url = '$baseUrl/episode'; // halaman pertama

    while (url != null) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Gagal memuat episode');
      }
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      // addAll: tambahkan hasil halaman ini ke list utama
      episodes.addAll(results.map((json) => Episode.fromJson(json)));
      // pindah ke halaman berikutnya (null -> loop berhenti)
      url = data['info']['next'];
    }
    return episodes;
  }
}
