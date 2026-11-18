// =============================================================
// MAIN.DART - titik awal aplikasi
// =============================================================
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/favorite.dart';
import 'models/user.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

// main() dibuat async karena kita perlu menunggu (await) Hive dan
// SharedPreferences siap sebelum aplikasi dijalankan.
void main() async {
  // Memastikan Flutter sudah siap sebelum memanggil kode async
  // di main(). Tanpa ini aplikasi bisa crash (Modul VI).
  WidgetsFlutterBinding.ensureInitialized();

  // ---------- HIVE ----------
  // 1. Inisialisasi Hive & tentukan lokasi penyimpanan database
  await Hive.initFlutter();
  // 2. Daftarkan adapter (hasil generate build_runner) agar Hive
  //    mengerti cara menyimpan object User & Favorite
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FavoriteAdapter());
  // 3. Buka box (anggap saja "tabel") yang akan dipakai
  await Hive.openBox<User>('users');
  await Hive.openBox<Favorite>('favorites');

  // ---------- SHARED PREFERENCES ----------
  // Cek apakah user sebelumnya sudah login (dan belum logout).
  // Jika iya, aplikasi langsung membuka HomeScreen tanpa login ulang.
  final prefs = await SharedPreferences.getInstance();
  final bool isLogin = prefs.getBool('isLogin') ?? false;
  final String username = prefs.getString('username') ?? '';

  runApp(MainApp(isLogin: isLogin, username: username));
}

class MainApp extends StatelessWidget {
  final bool isLogin;
  final String username;

  const MainApp({super.key, required this.isLogin, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spaceflight News',
      // Tema global: AppBar biru-ungu dengan teks putih seperti contoh soal
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF5B63F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5B63F5),
          foregroundColor: Colors.white,
        ),
      ),
      // Halaman pertama ditentukan oleh status login di SharedPreferences
      home: isLogin ? HomeScreen(username: username) : const LoginScreen(),
    );
  }
}
