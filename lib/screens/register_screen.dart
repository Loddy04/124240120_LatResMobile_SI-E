// =============================================================
// REGISTER SCREEN (Modul VI - Hive)
// =============================================================
// Membuat akun baru dan menyimpannya ke Hive box 'users'.
// Akun inilah yang nanti dicocokkan saat login.
//
// ALUR:
//   1. Validasi: kosong?              -> SnackBar merah
//   2. Username sudah dipakai?        -> SnackBar merah
//   3. Simpan: box.put(username, User(...))
//   4. SnackBar hijau, lalu kembali ke Login (Navigator.pop)
//
// 🟢 FILE INI BISA DISALIN UTUH ke proyek baru.
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // SnackBar merah untuk pesan error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // ----- VALIDASI 1: tidak boleh kosong -----
    if (username.isEmpty || password.isEmpty) {
      _showError('Username dan password tidak boleh kosong!');
      return;
    }
    // (Jika soal minta, tambahkan validasi lain di sini, contoh:)
    // if (password.length < 6) {
    //   _showError('Password minimal 6 karakter!');
    //   return;
    // }

    // Box 'users' sudah dibuka di main.dart
    final box = Hive.box<User>('users');

    // ----- VALIDASI 2: username belum dipakai -----
    // containsKey(key) -> true jika key tersebut sudah ada di box
    if (box.containsKey(username)) {
      _showError('Username sudah terdaftar, gunakan username lain!');
      return;
    }

    // ----- SIMPAN AKUN -----
    // box.put(KEY, VALUE)
    //   KEY   = username  -> saat login cukup box.get(username)
    //   VALUE = object User
    // (Kalau pakai box.add(), key-nya otomatis 0,1,2... sehingga untuk
    //  mencari akun harus mengecek satu per satu.)
    await box.put(username, User(username: username, password: password));

    if (mounted) {
      // SnackBar hijau sebagai tanda berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Register berhasil, silakan login!'),
          backgroundColor: Colors.green,
        ),
      );
      // pop = tutup halaman ini -> kembali ke halaman sebelumnya (Login)
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar OTOMATIS memunculkan tombol back (←) karena halaman ini
      // dibuka dengan Navigator.push dari Login
      appBar: AppBar(title: const Text('Register'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Daftar Akun Baru',
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
                obscureText: true, // sembunyikan password
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _register, child: const Text('Daftar')),
            ],
          ),
        ),
      ),
    );
  }
}
