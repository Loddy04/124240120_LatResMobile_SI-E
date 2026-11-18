// =============================================================
// DETAIL SCREEN - Halaman Detil
// =============================================================
// - Data diambil dari API berdasarkan id: /v4/{menu}/{id}/
// - Menampilkan gambar, judul, author, tanggal publish, summary
// - Tombol hati di AppBar  -> tambah / hapus favorite (disimpan di Hive)
// - Tombol "Buka Web"      -> membuka situs resmi berita (url_launcher)
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_service.dart';
import '../models/favorite.dart';
import '../models/space_item.dart';

class DetailScreen extends StatefulWidget {
  final String menu; // 'articles' / 'blogs' / 'reports'
  final int id; // id data yang akan diambil detailnya

  const DetailScreen({super.key, required this.menu, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Bertipe nullable (?) karena data belum ada saat halaman baru dibuka
  SpaceItem? item;
  bool isLoading = true;
  String? errorMessage;

  // Box favorite yang sudah dibuka di main.dart
  final Box<Favorite> favoriteBox = Hive.box<Favorite>('favorites');

  // Key unik data ini di box favorite, misal "articles_40887"
  String get favoriteKey => Favorite.makeKey(widget.menu, widget.id);

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final data = await ApiService.getDetail(widget.menu, widget.id);
      setState(() {
        item = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat detail. Periksa koneksi internet.';
        isLoading = false;
      });
    }
  }

  // Menambah atau menghapus data dari favorite (toggle)
  void _toggleFavorite() {
    if (item == null) return; // data belum siap

    // Sembunyikan snackbar sebelumnya agar tidak menumpuk
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (favoriteBox.containsKey(favoriteKey)) {
      // Sudah favorite -> hapus
      favoriteBox.delete(favoriteKey);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dihapus dari favorite')),
      );
    } else {
      // Belum favorite -> simpan ke Hive dengan key unik
      favoriteBox.put(
        favoriteKey,
        Favorite(
          menu: widget.menu,
          itemId: item!.id,
          title: item!.title,
          author: item!.author,
          imageUrl: item!.imageUrl,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ditambahkan ke favorite')),
      );
    }
  }

  // Membuka url situs resmi menggunakan package url_launcher
  Future<void> _openWeb() async {
    final uri = Uri.parse(item!.url);
    // LaunchMode.externalApplication -> dibuka di aplikasi browser
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka website'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: [
          // ValueListenableBuilder "mendengarkan" perubahan pada box favorite.
          // Jadi ikon hati otomatis berubah (♡ / ♥) setiap kali data
          // ditambah/dihapus, tanpa perlu memanggil setState (Modul VI).
          // keys: [favoriteKey] -> hanya rebuild jika key ini yang berubah
          ValueListenableBuilder(
            valueListenable: favoriteBox.listenable(keys: [favoriteKey]),
            builder: (context, Box<Favorite> box, _) {
              final isFavorite = box.containsKey(favoriteKey);
              return IconButton(
                tooltip: isFavorite ? 'Hapus dari favorite' : 'Tambah ke favorite',
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              );
            },
          ),
        ],
      ),
      // Tombol "Buka Web" hanya muncul jika data sudah berhasil dimuat
      floatingActionButton: item == null
          ? null
          : FloatingActionButton(
              tooltip: 'Buka Web',
              onPressed: _openWeb,
              child: const Icon(Icons.open_in_new),
            ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    // Tanda "!" dipakai karena item nullable, tapi di titik ini
    // kita sudah yakin datanya ada (Modul V)
    final data = item!;

    return SingleChildScrollView(
      // padding bawah agar teks terakhir tidak tertutup tombol FAB
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- GAMBAR ----------
          Image.network(
            data.imageUrl,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            // Exception handling jika gambar gagal dimuat
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 250,
                color: Colors.grey.shade300,
                child: const Center(child: Icon(Icons.broken_image, size: 64)),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- JUDUL ----------
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // ---------- AUTHOR ----------
                Text(data.author, style: const TextStyle(color: Colors.grey)),
                // ---------- TANGGAL PUBLISH ----------
                Text(
                  data.publishedAt,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                // ---------- SUMMARY ----------
                Text(
                  data.summary,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
