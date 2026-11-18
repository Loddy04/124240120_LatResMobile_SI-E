// =============================================================
// MAIN.DART - titik awal aplikasi Hydra Games
// =============================================================
// ALUR APLIKASI:
//
//   main()
//    ├─ init Hive (box 'library')        -> data game milik user
//    ├─ init Notifikasi (bonus)
//    ├─ baca SharedPreferences 'isLogin' -> sudah login atau belum?
//    └─ runApp
//         ├─ sudah login -> MainScreen (BottomNavigationBar)
//         └─ belum login -> LoginScreen
//
//   MainScreen (BottomNavigationBar)
//    ├─ Tab 0: HomeScreen    -> list game dari API -> klik -> DetailScreen
//    ├─ Tab 1: LibraryScreen -> list game dari Hive -> klik -> DetailScreen
//    └─ Tab 2: ProfileScreen -> email (SP) + jumlah game (Hive) + Logout
//
//   DetailScreen -> tombol "+ Get" menyimpan ke Hive (+ notifikasi)
//
// PEMBAGIAN PENYIMPANAN (sering ditanya!):
//   - SharedPreferences : data kecil key-value -> status login & email
//   - Hive              : data object/list     -> daftar game di library
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/library_game.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';

// async karena ada proses yang harus ditunggu (await) sebelum runApp
void main() async {
  // WAJIB jika main() memakai await sebelum runApp, agar Flutter siap
  WidgetsFlutterBinding.ensureInitialized();

  // ---------- HIVE (Modul VI) ----------
  await Hive.initFlutter(); // 1. init & tentukan lokasi database
  Hive.registerAdapter(LibraryGameAdapter()); // 2. daftarkan adapter (.g.dart)
  await Hive.openBox<LibraryGame>('library'); // 3. buka box 'library'

  // ---------- NOTIFIKASI (Modul VII - bonus) ----------
  await NotificationService().init();

  // ---------- SHARED PREFERENCES (Modul VI) ----------
  // "?? false" -> kalau key belum pernah disimpan (null), anggap false
  final prefs = await SharedPreferences.getInstance();
  final bool isLogin = prefs.getBool('isLogin') ?? false;

  runApp(MainApp(isLogin: isLogin));
}

class MainApp extends StatelessWidget {
  final bool isLogin;

  const MainApp({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hydra Games',
      // ---------- TEMA GELAP (seperti contoh soal) ----------
      // Dengan mengatur tema di sini, semua halaman otomatis ikut
      // berwarna gelap tanpa perlu mengatur warna satu per satu.
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          primary: const Color(0xFF4A8CFF), // biru aksen
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E), // abu-abu gelap untuk kartu
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // Halaman pertama ditentukan status login.
      // Ini memenuhi syarat: halaman utama hanya bisa diakses setelah login.
      home: isLogin ? const MainScreen() : const LoginScreen(),
    );
  }
}
