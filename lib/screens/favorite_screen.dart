// =============================================================
// FAVORITE SCREEN
// =============================================================
// Soal:
//  a) data favorit disimpan di SharedPreferences (lihat FavoriteService)
//  b) hapus favorit dengan cara SWIPE        -> widget Dismissible
//  c) SnackBar setelah karakter dihapus
//  d) pesan jika daftar favorit masih kosong
//
// StatelessWidget cukup, karena perubahan diurus ValueListenableBuilder.
import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/favorite_service.dart';
import '../widgets/status_label.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Character>>(
      valueListenable: FavoriteService.favorites,
      builder: (context, favorites, _) {
        // (d) daftar masih kosong
        if (favorites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Belum ada karakter favorit',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final character = favorites[index];

            // (b) DISMISSIBLE: item bisa digeser untuk dihapus
            return Dismissible(
              // key WAJIB unik per item, supaya Flutter tahu item mana
              // yang digeser. Pakai id karakter.
              key: Key(character.id.toString()),
              // Arah swipe: dari kanan ke kiri
              direction: DismissDirection.endToStart,
              // Latar merah + ikon tempat sampah yang terlihat saat digeser
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              // Dipanggil setelah item selesai digeser keluar layar
              onDismissed: (direction) {
                // Hapus dari favorit (otomatis tersimpan ke SP &
                // memberi tahu semua halaman lewat ValueNotifier)
                FavoriteService.remove(character.id);

                // (c) SnackBar + tombol UNDO (bonus kecil)
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${character.name} dihapus dari favorit'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () => FavoriteService.add(character),
                    ),
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: NetworkImage(character.image),
                    onBackgroundImageError: (error, stackTrace) {},
                  ),
                  title: Text(
                    character.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: StatusLabel(status: character.status),
                  trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailScreen(characterId: character.id),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
