// =============================================================
// LOGIN SCREEN (Modul VI - Shared Preferences)
// =============================================================
// Ketentuan soal:
//  - Kredensial: email & password (bebas apa aja) -> TIDAK ADA register
//  - Informasi login disimpan di SharedPreferences
//
// Karena "bebas apa aja", validasinya cukup:
//  - email & password tidak boleh kosong
//  - email harus mengandung "@"
// Jika soal kalian MEWAJIBKAN register, lihat branch `main`
// (akun disimpan di Hive box 'users', login mencocokkan password).
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextEditingController: "remote" untuk membaca/mengubah isi TextField
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Fungsi bantu untuk SnackBar error berwarna merah
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _login() async {
    // trim() membuang spasi di awal & akhir input
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // ----- VALIDASI -----
    if (email.isEmpty || password.isEmpty) {
      _showError('Email dan password wajib diisi!');
      return; // hentikan fungsi, jangan lanjut login
    }
    if (!email.contains('@')) {
      _showError('Format email tidak valid!');
      return;
    }

    // ----- SIMPAN KE SHARED PREFERENCES -----
    // Format: prefs.set<TipeData>('key', nilai)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', true); // penanda sudah login
    await prefs.setString('email', email); // dipakai di halaman Profil

    // mounted: cek widget masih tampil setelah proses await.
    // Wajib sebelum memakai context setelah await (kalau tidak -> warning).
    if (!mounted) return;

    // pushReplacement: Login DIGANTI MainScreen, jadi tombol back
    // di MainScreen tidak bisa kembali ke Login (Modul IV)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  // dispose: membersihkan controller saat halaman ditutup (hemat memori)
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Dekorasi TextField dibuat fungsi agar tidak menulis ulang 2x
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // SingleChildScrollView: mencegah error "overflow" saat keyboard muncul
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            // start = rata kiri (logo & judul di kiri seperti contoh)
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo: ikon gamepad biru
              const Icon(Icons.gamepad, size: 96, color: Color(0xFF4A8CFF)),
              const SizedBox(height: 8),
              const Text(
                'Hydra Games',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress, // keyboard ada "@"
                decoration: _inputDecoration('Email', Icons.email),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true, // sembunyikan password
                decoration: _inputDecoration('Password', Icons.lock),
              ),
              const SizedBox(height: 24),
              // SizedBox lebar penuh -> tombol memanjang selebar layar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(), // sudut bulat penuh
                  ),
                  onPressed: _login,
                  child: const Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
