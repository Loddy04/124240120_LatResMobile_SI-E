// =============================================================
// WIDGET GAME CARD (Modul II - Widget kustom / reusable)
// =============================================================
// Kartu game dipakai di DUA tempat: Home dan Library. Daripada menulis
// kode tampilan yang sama 2x, kita buat satu widget lalu dipakai ulang.
//
// Isi kartu (sesuai soal): Thumbnail, Nama, Genre, Platform.
// Bagian kanan kartu (trailing) bisa diganti:
//   - Home    -> ikon panah ">"
//   - Library -> tombol delete merah
import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String thumbnail;
  final String genre;
  final String platform;
  final Widget trailing; // widget di sisi kanan kartu
  final VoidCallback onTap; // fungsi yang dijalankan saat kartu diklik

  const GameCard({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.genre,
    required this.platform,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      // clipBehavior: gambar ikut terpotong mengikuti sudut bulat Card
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap, // efek ripple + aksi saat diklik
        child: Row(
          children: [
            // ---------- THUMBNAIL ----------
            Image.network(
              thumbnail,
              width: 120,
              height: 100,
              fit: BoxFit.cover, // gambar memenuhi kotak (dipotong rapi)
              // Exception handling: jika gambar gagal dimuat,
              // tampilkan kotak abu-abu berisi ikon, bukan error merah
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 100,
                color: Colors.grey.shade800,
                child: const Icon(Icons.broken_image),
              ),
            ),
            const SizedBox(width: 12),
            // Expanded: kolom teks mengambil SISA lebar Row.
            // Tanpa Expanded, judul yang panjang akan overflow.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- NAMA ----------
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ---------- GENRE (badge abu-abu) ----------
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      genre,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ---------- PLATFORM ----------
                  Text(
                    platform,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            trailing,
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
