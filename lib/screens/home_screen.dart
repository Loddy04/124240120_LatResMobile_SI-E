// =============================================================
// HOME SCREEN - Halaman Utama
// =============================================================
// - AppBar menampilkan username yang login ("Hai, username!")
// - 3 menu: News, Blog, Reports -> membuka ListScreen sesuai menu
// - Tombol Log Out di bawah pilihan menu
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'list_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  // Username dikirim dari LoginScreen / main.dart lewat constructor
  // (passing data antar halaman - Modul IV)
  final String username;

  const HomeScreen({super.key, required this.username});

  void _logout(BuildContext context) async {
    // Hapus data login dari SharedPreferences,
    // sehingga saat aplikasi dibuka lagi user harus login ulang
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('username');

    if (context.mounted) {
      // pushAndRemoveUntil: pindah ke Login dan HAPUS semua halaman
      // sebelumnya dari tumpukan, jadi tombol back tidak bisa kembali ke Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hai, $username!'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Widget _MenuCard dibuat sendiri di bawah agar kode tidak berulang
          const _MenuCard(
            title: 'News',
            menu: 'articles', // nama endpoint di API
            icon: Icons.newspaper,
            description:
                'Get an overview of the latest SpaceFlight news, from various sources! Easily link your users to the right websites.',
          ),
          const _MenuCard(
            title: 'Blog',
            menu: 'blogs',
            icon: Icons.article_outlined,
            description:
                'Blogs often provide a more detailed overview of launches and missions. A must-have for the serious spaceflight enthusiast.',
          ),
          const _MenuCard(
            title: 'Reports',
            menu: 'reports',
            icon: Icons.analytics_outlined,
            description:
                'Space stations and other missions often publish their data. With SNAPI, you can include it in your app.',
          ),
          const SizedBox(height: 24),
          // Tombol Log Out berwarna merah di bawah pilihan menu
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _logout(context),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget kustom untuk satu kartu menu.
// Diawali "_" artinya private, hanya dipakai di file ini.
class _MenuCard extends StatelessWidget {
  final String title;
  final String menu;
  final IconData icon;
  final String description;

  const _MenuCard({
    required this.title,
    required this.menu,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      // InkWell membuat Card bisa diklik dan memberi efek ripple
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Kirim judul & nama menu ke ListScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListScreen(title: title, menu: menu),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Kotak ikon di sebelah kiri
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.deepPurple, size: 32),
              ),
              const SizedBox(width: 16),
              // Expanded agar teks mengisi sisa lebar dan bisa turun baris
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
