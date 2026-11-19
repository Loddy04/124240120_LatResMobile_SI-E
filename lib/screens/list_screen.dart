// =============================================================
// LIST SCREEN - Halaman List + Fitur Filter
// =============================================================
// Isi halaman:
//   - List data (news / blog / report) dari API
//   - Tiap item: thumbnail (leading), judul, author
//   - Chip filter berdasarkan author
//   - Ikon ♥ di AppBar untuk membuka halaman Favorite
//
// POLA AMBIL DATA API (dipakai di HAMPIR SEMUA halaman yang memuat API):
//   1. Siapkan variabel state : items, isLoading, errorMessage
//   2. initState()            : panggil fetchItems() saat halaman dibuka
//   3. fetchItems()           : try { ambil data } catch { simpan error }
//                               lalu setState -> layar digambar ulang
//   4. build()                : isLoading?  -> lingkaran loading
//                               error?      -> pesan error
//                               selain itu  -> tampilkan data
//
// CARA KERJA FILTER (di sisi aplikasi, TANPA request API lagi):
//   items         = SEMUA data dari API (tidak pernah diubah)
//   authors       = daftar author UNIK dari items -> dijadikan chip
//   selectedAuthor= chip yang sedang aktif (null = tidak ada filter)
//   filteredItems = items yang author-nya == selectedAuthor
//                   -> INILAH yang ditampilkan di ListView
//
// SAAT RESPONSI: cari [UBAH-LIST-1] sampai [UBAH-LIST-6].
import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/space_item.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';

class ListScreen extends StatefulWidget {
  // Data yang DITERIMA dari HomeScreen lewat constructor
  final String title; // judul AppBar, misal "News"
  final String menu; // potongan link API, misal "articles"

  const ListScreen({super.key, required this.title, required this.menu});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

// Class State: tempat menyimpan data yang BERUBAH-UBAH.
// Untuk mengakses variabel milik ListScreen di atas, pakai widget.xxx
// (contoh: widget.menu, widget.title).
class _ListScreenState extends State<ListScreen> {
  // ---------- 1. VARIABEL STATE ----------
  List<SpaceItem> items = []; // semua data dari API (awalnya kosong)
  bool isLoading = true; // true = sedang memuat -> tampilkan loading
  String? errorMessage; // null = tidak ada error. "?" = boleh null
  String? selectedAuthor; // chip yang aktif (null = tampilkan semua)

  // ---------- 2. initState ----------
  // Dipanggil OTOMATIS satu kali saat halaman pertama kali dibuat.
  // Tempat yang tepat untuk mengambil data dari API (Modul V).
  @override
  void initState() {
    super.initState(); // wajib dipanggil paling atas
    fetchItems();
  }

  // ---------- 3. AMBIL DATA ----------
  // Future<void> + async: fungsi ini butuh waktu (menunggu internet)
  Future<void> fetchItems() async {
    // Reset tampilan ke "loading" (berguna saat tombol Coba Lagi ditekan)
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // try-catch: jika terjadi error di dalam "try" (tidak ada internet,
    // server error, JSON tidak sesuai), program lompat ke "catch"
    // dan TIDAK crash.
    try {
      // 🔧 [UBAH-LIST-1] PANGGIL FUNGSI API
      // Ganti dengan fungsi list di api_service.dart milikmu,
      // misal: await ApiService.getGames();
      final data = await ApiService.getList(widget.menu);

      // setState: ubah data LALU gambar ulang layar.
      // Tanpa setState, data sudah masuk tapi layar tetap loading.
      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data. Periksa koneksi internet.';
        isLoading = false;
      });
    }
  }

  // ---------- FILTER: daftar pilihan chip ----------
  // "get" = getter, dipanggil seperti variabel (authors), tapi nilainya
  // dihitung ulang setiap kali dipakai.
  //   items.map((e) => e.author) -> ambil author dari setiap item
  //   .toSet()                   -> hapus yang dobel (Set = tanpa duplikat)
  //   .toList()                  -> ubah lagi menjadi List
  // 🔧 [UBAH-LIST-2] FIELD YANG DIFILTER
  // Ganti e.author (di sini DAN di filteredItems) dengan field lain,
  // misal e.genre, jika soal minta filter berdasarkan genre.
  List<String> get authors => items.map((e) => e.author).toSet().toList();

  // ---------- FILTER: data yang ditampilkan ----------
  // .where(kondisi) -> ambil HANYA item yang kondisinya true
  List<SpaceItem> get filteredItems {
    if (selectedAuthor == null) return items; // tidak ada filter -> semua
    return items.where((e) => e.author == selectedAuthor).toList();
  }

  // ---------- 4. TAMPILAN ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // actions = tombol-tombol di kanan AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorite', // teks yang muncul saat ditekan lama
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // Isi body dipisah ke fungsi sendiri supaya build() tetap rapi.
  // Fungsi ini memilih tampilan berdasarkan state.
  Widget _buildBody() {
    // (a) Masih loading -> indikator berputar di tengah
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // (b) Terjadi error -> pesan + tombol coba lagi
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // tinggi Column = setinggi isinya
          children: [
            Text(errorMessage!), // "!" = yakin tidak null (sudah dicek di if)
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: fetchItems, // ulangi ambil data
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // (c) Data berhasil dimuat -> chip filter (atas) + list (bawah)
    return Column(
      children: [
        // ---------- FILTER CHIP ----------
        // Soal tidak minta filter? Hapus SizedBox ini seluruhnya, lalu
        // ganti filteredItems menjadi items di ListView di bawah.
        SizedBox(
          height: 56, // ListView horizontal WAJIB diberi tinggi
          child: ListView(
            scrollDirection: Axis.horizontal, // geser ke samping
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            // Ubah setiap author menjadi satu FilterChip
            children: authors.map((author) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(author),
                  // selected: chip tampil "tercentang" jika true
                  selected: selectedAuthor == author,
                  // onSelected: dipanggil saat chip diklik.
                  // `selected` = status chip SETELAH diklik.
                  onSelected: (selected) {
                    setState(() {
                      // Klik chip yang belum aktif -> selected = true
                      //   -> selectedAuthor = author (filter aktif)
                      // Klik chip yang sudah aktif -> selected = false
                      //   -> selectedAuthor = null   (filter mati)
                      selectedAuthor = selected ? author : null;
                    });
                    // setState membuat build() jalan lagi, sehingga
                    // filteredItems dihitung ulang & list ikut berubah.
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // ---------- LIST DATA ----------
        // Expanded WAJIB: ListView di dalam Column harus diberi batas
        // tinggi. Expanded = "ambil semua sisa tinggi layar".
        Expanded(
          // ListView.builder: membuat item satu per satu sesuai kebutuhan
          // (hemat memori untuk data banyak)
          child: ListView.builder(
            itemCount: filteredItems.length, // jumlah item
            // itemBuilder dipanggil untuk SETIAP index (0, 1, 2, ...)
            itemBuilder: (context, index) {
              final item = filteredItems[index]; // data ke-index
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                // ListTile = baris siap pakai: leading | title/subtitle | trailing
                child: ListTile(
                  leading: SizedBox(
                    width: 80,
                    height: 56,
                    child: Image.network(
                      // 🔧 [UBAH-LIST-3] field GAMBAR
                      item.imageUrl,
                      fit: BoxFit.cover, // gambar memenuhi kotak, dipotong rapi
                      // EXCEPTION HANDLING gambar (diminta soal):
                      // jika gambar gagal dimuat (url rusak / kosong /
                      // tidak ada internet), tampilkan ikon pengganti
                      // alih-alih error.
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 32);
                      },
                    ),
                  ),
                  title: Text(
                    // 🔧 [UBAH-LIST-4] field JUDUL
                    item.title,
                    maxLines: 2, // maksimal 2 baris
                    overflow: TextOverflow.ellipsis, // sisanya jadi "..."
                  ),
                  // 🔧 [UBAH-LIST-5] field KETERANGAN (author/genre/dll.)
                  subtitle: Text(item.author),
                  onTap: () {
                    // Buka detail sambil mengirim menu & id data yang diklik
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            // 🔧 [UBAH-LIST-6] data yang dikirim ke DetailScreen
                            DetailScreen(menu: widget.menu, id: item.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
