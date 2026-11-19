// =============================================================
// HOME SCREEN - Halaman Utama
// =============================================================
// Isi halaman:
//   - AppBar "Hai, username!" (username dikirim dari Login / main.dart)
//   - 3 kartu menu: News, Blog, Reports -> membuka ListScreen
//   - Tombol Log Out di bawah menu
//
// KUNCI HALAMAN INI: setiap kartu membawa nilai `menu` yang PERSIS SAMA
// dengan potongan link API ('articles', 'blogs', 'reports').
// Nilai itu dikirim ke ListScreen -> ApiService -> jadi link:
//   'https://api.spaceflightnewsapi.net/v4/' + menu + '/'
//
// SAAT RESPONSI: cari [UBAH-HOME-1] untuk mengganti/menambah menu.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'list_screen.dart';
import 'login_screen.dart';

// StatelessWidget: halaman ini tidak punya data yang berubah.
class HomeScreen extends StatelessWidget {
  // Data yang DITERIMA dari halaman sebelumnya lewat constructor
  // (passing data antar halaman - Modul IV).
  // Cara kirim: HomeScreen(username: 'rahman')
  final String username;

  const HomeScreen({super.key, required this.username});

  // ---------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------
  // Bisa disalin ke halaman lain yang punya tombol logout.
  // Butuh import: shared_preferences & login_screen.dart
  void _logout(BuildContext context) async {
    // Hapus data login dari SharedPreferences, sehingga saat aplikasi
    // dibuka lagi, main.dart membaca isLogin = null -> ke LoginScreen.
    // Key HARUS SAMA dengan yang disimpan di login_screen.dart.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('username');
    // (prefs.clear() juga bisa: menghapus SEMUA data SharedPreferences)

    // context.mounted: cek halaman masih tampil setelah await
    if (context.mounted) {
      // pushAndRemoveUntil: buka Login dan HAPUS semua halaman sebelumnya
      // dari tumpukan. (route) => false artinya "jangan sisakan satu pun".
      // Hasilnya: di Login, tombol back tidak bisa kembali ke Home.
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
      // '$username' -> menempelkan isi variabel ke dalam teks
      appBar: AppBar(title: Text('Hai, $username!'), centerTitle: true),
      // ListView (bukan Column) supaya bisa di-scroll di layar kecil
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔧 [UBAH-HOME-1] DAFTAR MENU
          // Setiap blok _MenuCard = satu kartu menu.
          //   title       : teks di kartu & judul AppBar halaman list
          //   menu        : potongan link API (HARUS sama persis dengan link)
          //   icon        : ikon di kiri kartu
          //   description : teks kecil di bawah judul
          // Tambah menu = salin satu blok. Kurangi menu = hapus satu blok.
          const _MenuCard(
            title: 'News',
            menu: 'articles', // -> .../v4/articles/
            icon: Icons.newspaper,
            description:
                'Get an overview of the latest SpaceFlight news, from various sources! Easily link your users to the right websites.',
          ),
          const _MenuCard(
            title: 'Blog',
            menu: 'blogs', // -> .../v4/blogs/
            icon: Icons.article_outlined,
            description:
                'Blogs often provide a more detailed overview of launches and missions. A must-have for the serious spaceflight enthusiast.',
          ),
          const _MenuCard(
            title: 'Reports',
            menu: 'reports', // -> .../v4/reports/
            icon: Icons.analytics_outlined,
            description:
                'Space stations and other missions often publish their data. With SNAPI, you can include it in your app.',
          ),
          const SizedBox(height: 24),
          // Tombol Log Out berwarna merah di bawah pilihan menu
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // warna tombol
                foregroundColor: Colors.white, // warna teks
              ),
              // () => _logout(context): pakai arrow function karena
              // _logout butuh parameter context
              onPressed: () => _logout(context),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// WIDGET KUSTOM: satu kartu menu (Modul II)
// =============================================================
// Dibuat class sendiri supaya kode kartu tidak ditulis 3 kali.
// Nama diawali "_" = private, hanya bisa dipakai di file ini.
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
      elevation: 3, // bayangan kartu
      margin: const EdgeInsets.only(bottom: 16),
      // InkWell membuat Card bisa diklik + efek gelombang (ripple)
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Pindah ke ListScreen sambil MENGIRIM title & menu.
          // Navigator.push = halaman baru DITUMPUK, bisa kembali (back).
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListScreen(title: title, menu: menu),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          // Row = susun ke SAMPING (ikon | teks)
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
              // Expanded: kolom teks mengambil SISA lebar Row.
              // Tanpa Expanded, teks panjang akan overflow (keluar layar).
              Expanded(
                // Column = susun ke BAWAH (judul, deskripsi)
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // rata kiri
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
