// =============================================================
// PROFILE SCREEN - "Profil" (Modul VI)
// =============================================================
// Ketentuan soal:
//  - Email           -> diambil dari SharedPreferences
//  - Jumlah game     -> diambil dari Hive (box.length)
//  - Tombol logout   -> kembali ke Login Page
//
// Di halaman ini kita memakai DUA sumber data sekaligus:
//  1. SharedPreferences (async) -> dibaca di initState lalu setState
//  2. Hive (reaktif)            -> ValueListenableBuilder
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/library_game.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String email = '-';

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  // Membaca email dari SharedPreferences.
  // Tidak bisa langsung di build() karena getInstance() bersifat async.
  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '-';
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // remove: hapus key tertentu. (Alternatif: prefs.clear() hapus SEMUA)
    await prefs.remove('isLogin');
    await prefs.remove('email');

    // Catatan: data library di Hive SENGAJA tidak dihapus, jadi
    // saat login lagi game yang dimiliki masih ada.

    if (!mounted) return;
    // pushAndRemoveUntil + (route) => false:
    // buka Login dan HAPUS semua halaman sebelumnya dari tumpukan,
    // sehingga tombol back tidak bisa kembali ke MainScreen.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // isi di tengah layar
          children: [
            // Avatar bulat
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade800,
              child: const Icon(Icons.person, size: 60, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // ---------- EMAIL (SharedPreferences) ----------
            _infoRow('Email:', email),
            const SizedBox(height: 12),

            // ---------- JUMLAH GAME (Hive) ----------
            // Pakai ValueListenableBuilder agar angkanya langsung berubah
            // saat game ditambah/dihapus (karena IndexedStack, halaman
            // ini tidak di-build ulang saat pindah tab).
            ValueListenableBuilder(
              valueListenable: Hive.box<LibraryGame>('library').listenable(),
              builder: (context, Box<LibraryGame> box, _) {
                // box.length = jumlah data di dalam box
                return _infoRow('Games Dimiliki:', '${box.length}');
              },
            ),
            const SizedBox(height: 32),

            // ---------- TOMBOL LOGOUT ----------
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: _logout,
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Baris label (kiri) & nilai (kanan)
  Widget _infoRow(String label, String value) {
    return Row(
      // spaceBetween: label di ujung kiri, nilai di ujung kanan
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
