// =============================================================
// LOGIN SCREEN (Modul VI - Shared Preferences)
// =============================================================
// - Login hanya bisa memakai akun yang sudah di-register (disimpan di Hive)
// - Jika gagal -> SnackBar merah
// - Jika berhasil -> simpan status login ke SharedPreferences, lalu ke
//   MainScreen (halaman dengan BottomNavigationBar)
//
// Soal: "Login & Register dengan menerapkan shared preferences serta
// local database" -> local database = Hive (akun), SP = sesi login.
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/favorite_service.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk membaca isi TextField
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Menampilkan SnackBar merah untuk pesan error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi: field tidak boleh kosong
    if (username.isEmpty || password.isEmpty) {
      _showError('Username dan password tidak boleh kosong!');
      return;
    }

    // Ambil box 'users' yang sudah dibuka di main.dart
    final box = Hive.box<User>('users');
    // Akun disimpan dengan key = username (lihat register_screen.dart),
    // jadi kita bisa langsung mengambilnya dengan box.get(username)
    final User? user = box.get(username);

    // Cek apakah akun ada dan password-nya cocok
    if (user == null || user.password != password) {
      _showError('Login Gagal! Pastikan sudah Register atau cek password.');
      return;
    }

    // Login berhasil -> simpan ke SharedPreferences (key-value)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', true);
    await prefs.setString('username', username);

    // Muat daftar favorit milik user ini dari SharedPreferences
    await FavoriteService.load(username);

    // "mounted" memastikan widget masih ada sebelum memakai context
    // setelah proses async (await)
    if (mounted) {
      // pushReplacement: halaman login diganti oleh MainScreen,
      // sehingga tombol back tidak kembali ke halaman login (Modul IV)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(username: username)),
      );
    }
  }

  // dispose dipanggil saat halaman dihapus, untuk membersihkan controller
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Center(
        // SingleChildScrollView supaya tidak overflow saat keyboard muncul
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Silakan Login',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true, // menyembunyikan password (•••)
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              const SizedBox(height: 8),
              TextButton(
                // push biasa: halaman register ditumpuk di atas login,
                // sehingga bisa kembali dengan tombol back
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Belum punya akun? Daftar di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
