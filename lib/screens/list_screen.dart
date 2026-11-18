// =============================================================
// LIST SCREEN - Halaman List + Fitur Filter
// =============================================================
// - Menampilkan list data (news / blog / report) dari API
// - Tiap item: thumbnail (leading), judul, dan author
// - Filter berdasarkan author menggunakan Chip
// - Ikon hati di AppBar untuk membuka halaman Favorite
import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/space_item.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';

class ListScreen extends StatefulWidget {
  final String title; // judul AppBar, misal "News"
  final String menu; // endpoint API, misal "articles"

  const ListScreen({super.key, required this.title, required this.menu});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<SpaceItem> items = []; // semua data dari API
  bool isLoading = true; // penanda sedang memuat data
  String? errorMessage; // berisi pesan jika request gagal
  String? selectedAuthor; // chip yang sedang aktif (null = tidak ada filter)

  // initState dipanggil SEKALI saat halaman pertama dibuka,
  // tempat yang tepat untuk mengambil data dari API (Modul V)
  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // try-catch untuk menangani error (misal tidak ada internet)
    try {
      final data = await ApiService.getList(widget.menu);
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

  // Daftar author unik untuk dijadikan chip filter.
  // toSet() menghapus duplikat, lalu diubah lagi jadi List.
  List<String> get authors => items.map((e) => e.author).toSet().toList();

  // Data yang ditampilkan: jika ada chip aktif, hanya tampilkan
  // data yang author-nya sama dengan chip tersebut
  List<SpaceItem> get filteredItems {
    if (selectedAuthor == null) return items;
    return items.where((e) => e.author == selectedAuthor).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorite',
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

  Widget _buildBody() {
    // 1. Masih loading -> tampilkan indikator berputar
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Terjadi error -> tampilkan pesan & tombol coba lagi
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: fetchItems,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // 3. Data berhasil dimuat -> tampilkan chip filter + list
    return Column(
      children: [
        // ---------- FILTER CHIP ----------
        // Dibuat bisa di-scroll ke samping karena jumlah author bisa banyak
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            children: authors.map((author) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(author),
                  // chip terpilih jika author-nya sama dengan selectedAuthor
                  selected: selectedAuthor == author,
                  onSelected: (selected) {
                    setState(() {
                      // Klik chip -> aktifkan filter.
                      // Klik chip yang sama lagi -> matikan filter.
                      selectedAuthor = selected ? author : null;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // ---------- LIST DATA ----------
        // Expanded wajib dipakai karena ListView berada di dalam Column
        Expanded(
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  // Thumbnail gambar sebagai leading
                  leading: SizedBox(
                    width: 80,
                    height: 56,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      // EXCEPTION HANDLING: jika gambar gagal dimuat
                      // (url rusak / kosong / tidak ada internet),
                      // tampilkan ikon pengganti agar tidak error
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 32);
                      },
                    ),
                  ),
                  // Judul data
                  title: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis, // tampilkan "..." jika kepanjangan
                  ),
                  // Author data
                  subtitle: Text(item.author),
                  onTap: () {
                    // Buka detail dengan mengirim menu & id data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
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
