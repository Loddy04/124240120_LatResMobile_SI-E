// =============================================================
// API SERVICE (Modul V - "Class dengan Static Method")
// =============================================================
// Pusat semua fungsi untuk mengambil data dari API.
// Memakai static method sehingga bisa dipanggil langsung
// (ApiService.getList(...)) tanpa membuat object terlebih dahulu.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/space_item.dart';

class ApiService {
  // Base URL API. Menu-nya nanti ditambahkan di belakang:
  //   News    -> https://api.spaceflightnewsapi.net/v4/articles/
  //   Blogs   -> https://api.spaceflightnewsapi.net/v4/blogs/
  //   Reports -> https://api.spaceflightnewsapi.net/v4/reports/
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  // Mengambil LIST data sesuai menu ('articles', 'blogs', 'reports').
  static Future<List<SpaceItem>> getList(String menu) async {
    final response = await http.get(Uri.parse('$baseUrl/$menu/'));

    if (response.statusCode == 200) {
      // jsonDecode mengubah String JSON menjadi Map/List Dart
      final data = jsonDecode(response.body);
      // Data list ada di dalam key "results"
      final List<dynamic> results = data['results'];
      // Ubah setiap Map menjadi object SpaceItem lewat fromJson
      return results.map((json) => SpaceItem.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data $menu');
    }
  }

  // Mengambil DETAIL satu data berdasarkan id-nya.
  // Contoh: https://api.spaceflightnewsapi.net/v4/{menu}/{id}/
  static Future<SpaceItem> getDetail(String menu, int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$menu/$id/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SpaceItem.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail data');
    }
  }
}
