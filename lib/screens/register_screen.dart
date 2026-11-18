// =============================================================
// REGISTER SCREEN (Modul VI - Hive)
// =============================================================
// Membuat akun baru dan menyimpannya ke Hive box 'users'.
// Akun inilah yang nanti dipakai untuk login.
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi input kosong
    if (username.isEmpty || password.isEmpty) {
      _showError('Username dan password tidak boleh kosong!');
      return;
    }

    final box = Hive.box<User>('users');

    // Cek apakah username sudah dipakai akun lain
    if (box.containsKey(username)) {
      _showError('Username sudah terdaftar, gunakan username lain!');
      return;
    }

    // Simpan akun dengan key = username.
    // box.put(key, value) -> kalau pakai box.add() key-nya otomatis angka,
    // tapi dengan put kita bisa mencari akun langsung dengan box.get(username)
    await box.put(username, User(username: username, password: password));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Register berhasil, silakan login!'),
          backgroundColor: Colors.green,
        ),
      );
      // Kembali ke halaman login
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
      // AppBar otomatis memunculkan tombol back karena halaman ini
      // dibuka dengan Navigator.push
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
                obscureText: true,
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
