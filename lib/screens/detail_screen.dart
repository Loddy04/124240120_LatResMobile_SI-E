// =============================================================
// DETAIL SCREEN (Modul V + Modul VI + Modul VII)
// =============================================================
// Ketentuan soal - wajib menampilkan:
//   i.   Thumbnail sebagai hero image (paling atas & besar)
//   ii.  Genre & Platform
//   iii. Nama game
//   iv.  Tanggal rilis, Publisher & Developer
//   v.   Screenshots
//   vi.  Deskripsi
//   vii. Tombol "Get" yang UI-nya BERBEDA jika game sudah dimiliki
// + bisa kembali ke Home (tombol back otomatis dari AppBar)
// + loading indicator saat load data
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../api/api_service.dart';
import '../models/game.dart';
import '../models/library_game.dart';
import '../services/notification_service.dart';

class DetailScreen extends StatefulWidget {
  // Id dikirim dari Home / Library lewat constructor (Modul IV)
  final int gameId;

  const DetailScreen({super.key, required this.gameId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // "Game?" = nullable, karena saat halaman baru dibuka datanya belum ada
  Game? game;
  bool isLoading = true;
  String? errorMessage;

  // Ambil box yang sudah dibuka di main.dart (tidak perlu openBox lagi)
  final Box<LibraryGame> libraryBox = Hive.box<LibraryGame>('library');

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      // widget.gameId -> cara mengakses variabel milik StatefulWidget
      // dari dalam class State-nya
      final data = await ApiService.getGameDetail(widget.gameId);
      setState(() {
        game = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat detail game.';
        isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------
  // TAMBAH ke library (Hive) + notifikasi
  // ---------------------------------------------------------
  void _addToLibrary() {
    final g = game!; // "!" = kita yakin game tidak null di sini

    // box.put(KEY, VALUE)
    // KEY = id game -> 1 game hanya bisa masuk library 1 kali,
    // dan mudah dicek dengan containsKey(id) / dihapus dengan delete(id).
    // (Kalau pakai box.add(), key-nya otomatis 0,1,2... dan game yang
    //  sama bisa tersimpan dobel)
    libraryBox.put(
      g.id,
      LibraryGame(
        id: g.id,
        title: g.title,
        thumbnail: g.thumbnail,
        genre: g.genre,
        platform: g.platform,
      ),
    );

    // BONUS: notifikasi langsung (Modul VII)
    NotificationService().showInstantNotification(
      id: g.id,
      title: 'Game ditambahkan 🎮',
      body: '${g.title} berhasil masuk ke library kamu',
    );

    _showSnackBar('${g.title} ditambahkan ke library');
  }

  // HAPUS dari library (klik tombol "In Library")
  void _removeFromLibrary() {
    libraryBox.delete(game!.id);
    _showSnackBar('${game!.title} dihapus dari library');
  }

  void _showSnackBar(String message) {
    // hideCurrentSnackBar: tutup snackbar lama agar tidak antre
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Halaman dibuka dengan Navigator.push, jadi AppBar OTOMATIS
      // menampilkan tombol back (←) untuk kembali ke Home.
      appBar: AppBar(title: const Text('Detail')),
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

    final g = game!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- i. HERO IMAGE ----------
          Image.network(
            g.thumbnail,
            width: double.infinity, // selebar layar
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 220,
              color: Colors.grey.shade800,
              child: const Center(child: Icon(Icons.broken_image, size: 64)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- ii. GENRE & PLATFORM ----------
                Row(
                  children: [
                    // Genre: kotak dengan garis tepi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(g.genre),
                    ),
                    const SizedBox(width: 12),
                    Text(g.platform),
                  ],
                ),
                const SizedBox(height: 12),

                // ---------- iii. NAMA GAME ----------
                Text(
                  g.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- iv. RILIS, PUBLISHER, DEVELOPER ----------
                // Expanded di setiap kolom -> lebar dibagi rata 3 bagian
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _infoColumn('Release Date', g.releaseDate)),
                    Expanded(child: _infoColumn('Publisher', g.publisher)),
                    Expanded(child: _infoColumn('Developer', g.developer)),
                  ],
                ),
                const SizedBox(height: 24),

                // ---------- vii. TOMBOL GET / IN LIBRARY ----------
                _buildGetButton(),
                const SizedBox(height: 24),

                // ---------- v. SCREENSHOTS ----------
                const Text(
                  'Screenshots',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildScreenshots(g.screenshots),
                const SizedBox(height: 24),

                // ---------- vi. DESKRIPSI ----------
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  g.description,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Kolom kecil: label abu-abu di atas, nilai di bawah
  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value),
      ],
    );
  }

  // ---------------------------------------------------------
  // TOMBOL YANG BERUBAH SESUAI STATUS KEPEMILIKAN
  // ---------------------------------------------------------
  // ValueListenableBuilder "mendengarkan" box Hive. Setiap kali ada
  // put/delete, builder dijalankan ulang -> tombol berubah sendiri
  // TANPA setState. (Ini juga yang membuat Library & Profil ikut update)
  //
  // keys: [id] -> hanya rebuild kalau key game INI yang berubah
  Widget _buildGetButton() {
    return ValueListenableBuilder(
      valueListenable: libraryBox.listenable(keys: [game!.id]),
      builder: (context, Box<LibraryGame> box, _) {
        final bool owned = box.containsKey(game!.id);

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              // Sudah dimiliki -> abu-abu, belum -> biru
              backgroundColor: owned
                  ? Colors.grey.shade700
                  : const Color(0xFF4A8CFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Kondisi ? jikaTrue : jikaFalse (ternary operator)
            icon: Icon(owned ? Icons.check : Icons.add),
            label: Text(owned ? 'In Library' : 'Get'),
            onPressed: owned ? _removeFromLibrary : _addToLibrary,
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // SCREENSHOTS: list horizontal
  // ---------------------------------------------------------
  Widget _buildScreenshots(List<String> screenshots) {
    if (screenshots.isEmpty) {
      return const Text(
        'Tidak ada screenshot',
        style: TextStyle(color: Colors.grey),
      );
    }

    // ListView horizontal WAJIB diberi tinggi (SizedBox height),
    // kalau tidak akan error "unbounded height"
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal, // scroll ke samping
        itemCount: screenshots.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // ClipRRect: memotong gambar dengan sudut membulat
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              screenshots[index],
              width: 160,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 160,
                color: Colors.grey.shade800,
                child: const Icon(Icons.broken_image),
              ),
            ),
          );
        },
      ),
    );
  }
}
