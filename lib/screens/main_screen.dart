// =============================================================
// MAIN SCREEN - BottomNavigationBar (Modul IV - Navigation)
// =============================================================
// Soal: "Gunakan Bottom Navigation Bar untuk berpindah antara Home
// Screen dan Favorite Screen" (+ halaman Episode).
//
// Halaman ini hanya "wadah":
//  - AppBar: judul sesuai tab + tombol logout
//  - body  : halaman sesuai tab aktif
//  - bottomNavigationBar: Characters, Favorites, Episodes
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/favorite_service.dart';
import 'character_screen.dart';
import 'episode_screen.dart';
import 'favorite_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  final String username;

  const MainScreen({super.key, required this.username});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // tab yang sedang aktif

  // Judul AppBar untuk tiap tab (urutannya sama dengan tab)
  final List<String> _titles = const ['Rick & Morty', 'Favorites', 'Episodes'];

  // Halaman untuk tiap tab
  final List<Widget> _pages = const [
    CharacterScreen(),
    FavoriteScreen(),
    EpisodeScreen(),
  ];

  // ---------- LOGOUT ----------
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('username');
    // Kosongkan favorit di memori (data di SP tetap aman per user)
    FavoriteService.reset();

    if (!mounted) return;
    // Kembali ke Login & hapus semua halaman sebelumnya dari tumpukan
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
        title: Text(_titles[_currentIndex]),
        centerTitle: false, // judul rata kiri seperti contoh soal
        actions: [
          // Menampilkan username yang sedang login
          Center(
            child: Text(
              widget.username,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      // IndexedStack: halaman lain tetap "hidup" saat pindah tab,
      // jadi data API & isi kolom search tidak hilang / di-load ulang
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Characters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Episodes',
          ),
        ],
      ),
    );
  }
}
