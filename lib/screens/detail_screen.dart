// =============================================================
// DETAIL SCREEN - Halaman Detil
// =============================================================
// Isi halaman:
//   - Data diambil dari API berdasarkan id: /v4/{menu}/{id}/
//   - Gambar, judul, author, tanggal publish, summary
//   - Tombol ♥ di AppBar  -> tambah / hapus favorite (Hive)
//   - Tombol "Buka Web"   -> membuka situs resmi berita (url_launcher)
//
// CARA KERJA FAVORITE DI HALAMAN INI:
//   favoriteBox            = box Hive 'favorites' (dibuka di main.dart)
//   favoriteKey            = key unik data ini, misal "articles_40887"
//   containsKey(key)       = sudah difavoritkan atau belum?
//   put(key, Favorite(..)) = TAMBAH favorit
//   delete(key)            = HAPUS favorit
//   ValueListenableBuilder = ikon ♡/♥ berubah OTOMATIS saat box berubah
//
// SAAT RESPONSI: cari [UBAH-DETAIL-1] sampai [UBAH-DETAIL-5].
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_service.dart';
import '../models/favorite.dart';
import '../models/space_item.dart';

class DetailScreen extends StatefulWidget {
  // 🔧 [UBAH-DETAIL-1] DATA YANG DITERIMA dari halaman sebelumnya
  // Jika soalmu tidak punya "menu" (hanya 1 jenis data), cukup `id`.
  final String menu; // 'articles' / 'blogs' / 'reports'
  final int id; // id data yang akan diambil detailnya

  const DetailScreen({super.key, required this.menu, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // "SpaceItem?" = nullable, karena saat halaman baru dibuka datanya
  // BELUM ADA (masih diambil dari API).
  SpaceItem? item;
  bool isLoading = true;
  String? errorMessage;

  // Ambil box favorite yang SUDAH DIBUKA di main.dart
  final Box<Favorite> favoriteBox = Hive.box<Favorite>('favorites');

  // Key unik data ini di box favorite, misal "articles_40887".
  // "get" = dihitung setiap kali dipakai.
  String get favoriteKey => Favorite.makeKey(widget.menu, widget.id);

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  // Pola sama dengan list: try -> ambil data -> setState
  Future<void> fetchDetail() async {
    try {
      // 🔧 [UBAH-DETAIL-2] PANGGIL FUNGSI DETAIL API
      // misal: await ApiService.getGameDetail(widget.id);
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

  // ---------------------------------------------------------
  // TAMBAH / HAPUS FAVORITE (toggle = bolak-balik)
  // ---------------------------------------------------------
  // Dipanggil saat tombol ♥ di AppBar ditekan.
  void _toggleFavorite() {
    if (item == null) return; // data belum siap, abaikan

    // Tutup SnackBar sebelumnya supaya tidak antre/menumpuk
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (favoriteBox.containsKey(favoriteKey)) {
      // ===== SUDAH favorit -> HAPUS =====
      favoriteBox.delete(favoriteKey);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dihapus dari favorite')),
      );
    } else {
      // ===== BELUM favorit -> TAMBAH =====
      // box.put(KEY, VALUE) -> simpan object Favorite dengan key unik
      favoriteBox.put(
        favoriteKey,
        // 🔧 [UBAH-DETAIL-3] DATA YANG DISIMPAN KE FAVORIT
        // Harus sesuai field di models/favorite.dart.
        // "item!" -> "!" artinya kita yakin item tidak null di sini.
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
      // (Bonus notifikasi: panggil NotificationService di sini,
      //  lihat PANDUAN_RESPONSI.md bagian 8)
    }
    // Tidak perlu setState: ikon ♥ diurus ValueListenableBuilder di build()
  }

  // ---------------------------------------------------------
  // BUKA WEBSITE (package url_launcher)
  // ---------------------------------------------------------
  // Butuh: url_launcher di pubspec.yaml + <queries> di AndroidManifest.xml
  Future<void> _openWeb() async {
    // 🔧 [UBAH-DETAIL-4] field LINK WEB
    final uri = Uri.parse(item!.url);
    // externalApplication -> dibuka di aplikasi browser (Chrome, dll.)
    // launchUrl mengembalikan true jika berhasil dibuka
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
          // ValueListenableBuilder = "pendengar".
          // Ia mendengarkan box favorite; setiap kali isi box berubah
          // (put/delete), bagian builder dijalankan ULANG sehingga ikon
          // otomatis berganti ♡ <-> ♥ TANPA setState (Modul VI).
          //
          // listenable(keys: [favoriteKey]) -> hanya bereaksi jika key
          // data INI yang berubah (lebih hemat).
          ValueListenableBuilder(
            valueListenable: favoriteBox.listenable(keys: [favoriteKey]),
            // box = isi box terbaru, "_" = parameter yang tidak dipakai
            builder: (context, Box<Favorite> box, _) {
              final isFavorite = box.containsKey(favoriteKey);
              return IconButton(
                tooltip: isFavorite ? 'Hapus dari favorite' : 'Tambah ke favorite',
                icon: Icon(
                  // ternary: kondisi ? jikaTrue : jikaFalse
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              );
            },
          ),
        ],
      ),
      // Tombol mengambang "Buka Web", hanya muncul jika data sudah ada.
      // (null = tidak ada tombol)
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

    // Di titik ini data pasti sudah ada, jadi aman memakai "!"
    // dan disimpan ke variabel pendek `data` supaya mudah ditulis.
    final data = item!;

    // 🔧 [UBAH-DETAIL-5] FIELD YANG DITAMPILKAN
    // Tampilkan SEMUA field yang wajib menurut soal.
    // Tambah field = tambah Text(data.namaField).
    return SingleChildScrollView(
      // padding bawah agar teks terakhir tidak tertutup tombol FAB
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // rata kiri
        children: [
          // ---------- GAMBAR ----------
          Image.network(
            data.imageUrl,
            width: double.infinity, // selebar layar
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
                  textAlign: TextAlign.justify, // rata kanan-kiri
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
