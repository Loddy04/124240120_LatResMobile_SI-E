// =============================================================
// MAIN.DART - titik awal aplikasi Rick & Morty Character Explorer
// =============================================================
// ALUR APLIKASI:
//
//   main()
//    ├─ init Hive (box 'users')            -> akun hasil register
//    ├─ baca SharedPreferences 'isLogin'   -> sudah login atau belum?
//    ├─ jika login: FavoriteService.load() -> favorit dari SharedPreferences
//    └─ runApp
//         ├─ sudah login -> MainScreen (BottomNavigationBar)
//         └─ belum login -> LoginScreen  <-> RegisterScreen
//
//   MainScreen (AppBar + tombol logout, BottomNavigationBar)
//    ├─ Tab 0: CharacterScreen -> search, filter status, ♥
//    │                            -> klik -> DetailScreen (♥ + SnackBar)
//    ├─ Tab 1: FavoriteScreen  -> swipe untuk hapus
//    └─ Tab 2: EpisodeScreen   -> nama & air_date
//
// PENYIMPANAN:
//   - Hive              : akun user (local database)
//   - SharedPreferences : status login, username, & daftar FAVORIT
//                         (soal mewajibkan favorit di SharedPreferences)
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/favorite_service.dart';

void main() async {
  // Wajib karena ada await sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  // ---------- HIVE ----------
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('users');

  // ---------- SHARED PREFERENCES ----------
  final prefs = await SharedPreferences.getInstance();
  final bool isLogin = prefs.getBool('isLogin') ?? false;
  final String username = prefs.getString('username') ?? '';

  // Jika masih login, langsung muat favorit milik user tersebut
  if (isLogin) {
    await FavoriteService.load(username);
  }

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
      title: 'Rick & Morty',
      // Tema terang, mirip contoh di soal
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7), // abu-abu muda
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF2F2F7),
          titleTextStyle: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      // Syarat soal: halaman utama HANYA bisa diakses setelah login
      home: isLogin ? MainScreen(username: username) : const LoginScreen(),
    );
  }
}
