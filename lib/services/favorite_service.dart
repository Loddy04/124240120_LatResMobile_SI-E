// =============================================================
// FAVORITE SERVICE (Modul VI - SharedPreferences + Modul III - State)
// =============================================================
// Soal:
//  - "Simpan data favorite menggunakan Shared Preferences agar tidak
//     hilang ketika aplikasi ditutup."
//  - "Pastikan perubahan favorite langsung diperbarui pada Home Screen
//     dan Favorite Screen."
//
// MASALAH: SharedPreferences TIDAK reaktif (beda dengan Hive yang punya
// .listenable()). Kalau favorit diubah di Detail, Home & Favorite tidak
// tahu ada perubahan.
//
// SOLUSI: simpan daftar favorit di sebuah ValueNotifier.
//  - ValueNotifier = "kotak berisi nilai" yang memberi tahu semua
//    pendengarnya setiap kali nilainya diganti.
//  - Semua halaman membungkus UI-nya dengan ValueListenableBuilder
//    yang mendengarkan notifier ini -> otomatis rebuild.
//  - Setiap perubahan juga langsung disimpan ke SharedPreferences.
//
//   Detail/Home/Favorite --toggle()--> FavoriteService
//                                       ├─ favorites.value = list baru  -> semua UI update
//                                       └─ simpan ke SharedPreferences   -> data awet
//
// CARA SIMPAN LIST OBJECT KE SHARED PREFERENCES:
//   List<Character> -> setiap item: toJson() -> jsonEncode() -> String
//   -> disimpan dengan prefs.setStringList('favorites', listString)
//   Saat dibaca: getStringList -> jsonDecode -> Character.fromJson
import 'dart:convert';

import 'package:flutter/foundation.dart'; // untuk ValueNotifier
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

class FavoriteService {
  // static -> hanya ada SATU notifier untuk seluruh aplikasi,
  // bisa diakses dari mana saja: FavoriteService.favorites
  static final ValueNotifier<List<Character>> favorites =
      ValueNotifier<List<Character>>([]);

  // Key penyimpanan dibuat PER USER, contoh: "favorites_rahman".
  // Jadi setiap akun punya daftar favorit sendiri.
  static String _key = 'favorites';

  // Baca favorit milik user dari SharedPreferences.
  // Dipanggil di main.dart (jika sudah login) dan setelah login berhasil.
  static Future<void> load(String username) async {
    _key = 'favorites_$username';
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(_key) ?? [];
    favorites.value = saved
        .map((item) => Character.fromJson(jsonDecode(item)))
        .toList();
  }

  // Simpan seluruh list favorit ke SharedPreferences
  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = favorites.value
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    await prefs.setStringList(_key, data);
  }

  // Cek apakah karakter dengan id tertentu sudah difavoritkan.
  // any = true jika ADA minimal satu item yang memenuhi kondisi.
  static bool isFavorite(int id) {
    return favorites.value.any((c) => c.id == id);
  }

  // Tambah ke favorit
  static Future<void> add(Character character) async {
    // PENTING: buat LIST BARU ([...lama, baru]), jangan pakai
    // favorites.value.add(...). ValueNotifier hanya memberi tahu
    // pendengar jika nilai .value DIGANTI dengan object baru.
    favorites.value = [...favorites.value, character];
    await _save();
  }

  // Hapus dari favorit
  static Future<void> remove(int id) async {
    // where: ambil semua kecuali id yang dihapus -> list baru
    favorites.value = favorites.value.where((c) => c.id != id).toList();
    await _save();
  }

  // Tambah jika belum ada, hapus jika sudah ada.
  // Mengembalikan true jika SEKARANG menjadi favorit (untuk teks SnackBar).
  static Future<bool> toggle(Character character) async {
    if (isFavorite(character.id)) {
      await remove(character.id);
      return false;
    } else {
      await add(character);
      return true;
    }
  }

  // Dipanggil saat logout: kosongkan list di MEMORI saja, agar favorit
  // user lama tidak tampil untuk user berikutnya. Data di SharedPreferences
  // tetap ada, jadi saat user yang sama login lagi favoritnya kembali.
  static void reset() {
    favorites.value = [];
  }
}
