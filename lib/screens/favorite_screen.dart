// =============================================================
// FAVORITE SCREEN - Halaman Favorite
// =============================================================
// Menampilkan SEMUA data favorite (news, blog, report jadi satu).
// Memakai ValueListenableBuilder sehingga list otomatis ter-update,
// baik perubahan dilakukan di halaman ini maupun di halaman detail.
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/favorite.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Halaman ini cukup StatelessWidget karena perubahan UI
    // sudah diurus oleh ValueListenableBuilder, bukan setState
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite')),
      body: ValueListenableBuilder(
        // listenable() -> memberi tahu builder setiap ada perubahan di box
        valueListenable: Hive.box<Favorite>('favorites').listenable(),
        builder: (context, Box<Favorite> box, _) {
          // Jika belum ada favorite, tampilkan pesan
          if (box.isEmpty) {
            return const Center(child: Text('Belum ada data favorite'));
          }

          // Ambil semua data favorite menjadi List
          final favorites = box.values.toList();

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final fav = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: SizedBox(
                    width: 64,
                    height: 48,
                    child: Image.network(
                      fav.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 32);
                      },
                    ),
                  ),
                  title: Text(
                    fav.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(fav.author),
                  // Tombol hati merah -> hapus dari favorite.
                  // Setelah dihapus, ValueListenableBuilder otomatis
                  // membangun ulang list sehingga item langsung hilang.
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    tooltip: 'Hapus dari favorite',
                    onPressed: () {
                      // fav adalah HiveObject, jadi bisa langsung delete()
                      fav.delete();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dihapus dari favorite')),
                      );
                    },
                  ),
                  // Klik item -> buka detail-nya lagi
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailScreen(menu: fav.menu, id: fav.itemId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
