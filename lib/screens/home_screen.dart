// =============================================================
// HOME SCREEN - "Browse Games" (Modul III & V)
// =============================================================
// Ketentuan soal:
//  - daftar game ditampilkan dengan ListView
//  - tiap item: thumbnail, nama, genre, platform
//  - ada loading indicator saat load data
//  - klik game -> masuk ke Detail Page
//
// POLA FETCH API YANG DIPAKAI (hafalkan, dipakai di hampir semua soal):
//   1. Siapkan variabel: data, isLoading, errorMessage
//   2. initState()  -> panggil fungsi fetch
//   3. fetch        -> try { data = await Api...; } catch { error }
//                      lalu setState agar UI di-build ulang
//   4. build()      -> if loading: spinner
//                      else if error: pesan error
//                      else: tampilkan data
import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/game.dart';
import '../widgets/game_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. VARIABEL STATE
  List<Game> games = []; // data game dari API
  bool isLoading = true; // true = sedang memuat
  String? errorMessage; // null = tidak ada error

  // 2. initState: dipanggil SEKALI saat halaman pertama kali dibuat
  @override
  void initState() {
    super.initState();
    fetchGames();
  }

  // 3. FUNGSI FETCH
  Future<void> fetchGames() async {
    // Reset state (berguna saat tombol "Coba Lagi" ditekan)
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.getGames();
      setState(() {
        games = data;
        isLoading = false;
      });
    } catch (e) {
      // Masuk ke sini jika: tidak ada internet, server error,
      // atau format JSON tidak sesuai model
      setState(() {
        errorMessage = 'Gagal memuat game. Periksa koneksi internet.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // automaticallyImplyLeading: false -> tidak ada tombol back
      appBar: AppBar(
        title: const Text('Browse Games'),
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
    );
  }

  // 4. TAMPILAN BERDASARKAN STATE
  Widget _buildBody() {
    // a. Loading
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // b. Error -> pesan + tombol coba lagi
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column setinggi isinya saja
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(errorMessage!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: fetchGames,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // c. Data berhasil dimuat
    // ListView.builder: membuat item SECARA MALAS (hanya yang terlihat
    // di layar), cocok untuk data banyak (API ini berisi 400+ game)
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return GameCard(
          title: game.title,
          thumbnail: game.thumbnail,
          genre: game.genre,
          platform: game.platform,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Kirim id game ke DetailScreen lewat constructor.
            // DetailScreen akan mengambil detail lengkap dari API.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(gameId: game.id),
              ),
            );
          },
        );
      },
    );
  }
}
