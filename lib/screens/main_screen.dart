// =============================================================
// MAIN SCREEN - wadah BottomNavigationBar (Modul IV - Navigation)
// =============================================================
// Halaman ini TIDAK punya isi sendiri. Tugasnya hanya:
//  1. Menampilkan BottomNavigationBar (Beranda, Library, Profil)
//  2. Menampilkan halaman sesuai tab yang dipilih
//
// Konsepnya: simpan index tab aktif di variabel (_currentIndex).
// Saat tab diklik -> setState mengubah index -> body ikut berganti.
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // 0 = Beranda, 1 = Library, 2 = Profil

  // Daftar halaman, URUTANNYA harus sama dengan urutan item di
  // BottomNavigationBar di bawah.
  final List<Widget> _pages = const [
    HomeScreen(),
    LibraryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menampilkan SATU halaman sesuai index, tapi halaman
      // lain tetap "hidup" di belakang. Efeknya: saat pindah tab lalu
      // kembali ke Beranda, data game TIDAK di-load ulang dari API.
      // (Alternatif lebih sederhana: body: _pages[_currentIndex],
      //  tapi halaman akan dibuat ulang & fetch API lagi setiap pindah tab)
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // tab yang sedang aktif (diberi warna)
        onTap: (index) {
          // index = posisi tab yang diklik
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF4A8CFF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Library',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
