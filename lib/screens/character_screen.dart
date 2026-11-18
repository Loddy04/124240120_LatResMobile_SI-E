// =============================================================
// CHARACTER SCREEN - Home Screen (Modul III, V)
// =============================================================
// Soal:
//  a) daftar karakter dari API: foto, nama, status + tombol favorit
//  b) filter berdasarkan status (Alive, Dead, Unknown)
//  c) karakter dipilih -> Detail Screen
//  + loading state & error handling
//  + BONUS: pencarian berdasarkan nama
//
// BEDA DENGAN FILTER DI LATRES (branch main):
//  - latres  : filter di sisi APLIKASI (data sudah ada, disaring pakai where)
//  - di sini : filter di sisi API -> setiap chip diklik, request ulang ke
//              /character?status=alive (sesuai endpoint dari soal)
import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/character.dart';
import '../services/favorite_service.dart';
import '../widgets/status_label.dart';
import 'detail_screen.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  List<Character> characters = [];
  bool isLoading = true;
  String? errorMessage;

  // Status yang dipilih. '' (kosong) = semua status.
  String selectedStatus = '';
  // Isi kolom pencarian
  final _searchController = TextEditingController();

  // Pilihan chip filter: label yang tampil -> nilai untuk API
  final Map<String, String> statusOptions = const {
    'All': '',
    'Alive': 'alive',
    'Dead': 'dead',
    'Unknown': 'unknown',
  };

  @override
  void initState() {
    super.initState();
    fetchCharacters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCharacters() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Kirim status & nama yang sedang aktif ke API
      final data = await ApiService.getCharacters(
        status: selectedStatus,
        name: _searchController.text.trim(),
      );
      // mounted: cegah setState setelah widget sudah tidak ada
      if (!mounted) return;
      setState(() {
        characters = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Gagal memuat karakter. Periksa koneksi internet.';
        isLoading = false;
      });
    }
  }

  // Tombol ♥ di list: tambah/hapus favorit + SnackBar
  void _toggleFavorite(Character character) async {
    final bool nowFavorite = await FavoriteService.toggle(character);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowFavorite
              ? '${character.name} ditambahkan ke favorit'
              : '${character.name} dihapus dari favorit',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---------- BONUS: SEARCH BAR ----------
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: TextField(
            controller: _searchController,
            // textInputAction.search: tombol enter di keyboard jadi ikon cari
            textInputAction: TextInputAction.search,
            // onSubmitted: dijalankan saat user menekan enter/cari
            onSubmitted: (_) => fetchCharacters(),
            decoration: InputDecoration(
              hintText: 'Cari karakter...',
              prefixIcon: const Icon(Icons.search),
              // Tombol X untuk mengosongkan pencarian
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  fetchCharacters();
                },
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // ---------- FILTER STATUS (ChoiceChip) ----------
        // ChoiceChip = hanya SATU yang bisa aktif (beda dengan FilterChip
        // yang bisa banyak). Cocok untuk filter status.
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            // .entries -> mengubah Map menjadi daftar pasangan key-value
            children: statusOptions.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(entry.key), // teks yang tampil
                  selected: selectedStatus == entry.value,
                  onSelected: (_) {
                    setState(() => selectedStatus = entry.value);
                    fetchCharacters(); // request ulang dengan status baru
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // ---------- LIST ----------
        // Expanded wajib karena ListView ada di dalam Column
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildList() {
    // 1. Loading
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: fetchCharacters,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // 3. Data kosong (hasil filter/search tidak ditemukan)
    if (characters.isEmpty) {
      return const Center(child: Text('Karakter tidak ditemukan'));
    }

    // 4. Tampilkan data.
    // Dibungkus ValueListenableBuilder agar ikon ♥ langsung berubah saat
    // favorit diubah dari halaman MANA PUN (Detail / Favorites).
    return ValueListenableBuilder<List<Character>>(
      valueListenable: FavoriteService.favorites,
      builder: (context, favorites, _) {
        return ListView.builder(
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final character = characters[index];
            // Cek apakah karakter ini ada di daftar favorit
            final bool isFav = favorites.any((f) => f.id == character.id);

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                // ---------- FOTO (avatar bulat) ----------
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: NetworkImage(character.image),
                  // Exception handling jika gambar gagal dimuat
                  onBackgroundImageError: (error, stackTrace) {},
                ),
                // ---------- NAMA ----------
                title: Text(
                  character.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                // ---------- STATUS ----------
                subtitle: StatusLabel(status: character.status),
                // ---------- TOMBOL FAVORIT ----------
                trailing: IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () => _toggleFavorite(character),
                ),
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
            );
          },
        );
      },
    );
  }
}
