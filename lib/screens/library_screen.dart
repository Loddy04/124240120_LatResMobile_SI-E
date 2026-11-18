// =============================================================
// LIBRARY SCREEN - "Library Anda" (Modul VI - Hive)
// =============================================================
// Ketentuan soal:
//  - list game yang dimiliki: thumbnail, nama, genre, platform
//  - tombol delete untuk menghapus game dari library
//  - klik game -> Detail Page
//  - data disimpan & dikelola dengan Hive
//
// Halaman ini StatelessWidget karena perubahan tampilan diurus oleh
// ValueListenableBuilder (bukan setState). Begitu box berubah
// (ditambah dari Detail / dihapus di sini), list langsung ter-update.
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/library_game.dart';
import '../widgets/game_card.dart';
import 'detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Anda'),
        automaticallyImplyLeading: false,
      ),
      body: ValueListenableBuilder(
        // .listenable() berasal dari package hive_flutter
        valueListenable: Hive.box<LibraryGame>('library').listenable(),
        builder: (context, Box<LibraryGame> box, _) {
          // Library kosong -> tampilkan pesan
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'Library masih kosong.\nAyo Get game dari Beranda!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // box.values -> semua isi box, diubah menjadi List
          final games = box.values.toList();

          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return GameCard(
                title: game.title,
                thumbnail: game.thumbnail,
                genre: game.genre,
                platform: game.platform,
                // Tombol delete merah di sisi kanan
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Hapus dari library',
                  onPressed: () {
                    // Hapus berdasarkan KEY (= id game, lihat detail_screen).
                    // Alternatif: game.delete() karena LibraryGame
                    // extends HiveObject.
                    box.delete(game.id);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${game.title} dihapus dari library'),
                      ),
                    );
                  },
                ),
                onTap: () {
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
        },
      ),
    );
  }
}
