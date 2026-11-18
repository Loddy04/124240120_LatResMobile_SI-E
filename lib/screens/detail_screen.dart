// =============================================================
// DETAIL SCREEN (Modul V)
// =============================================================
// Soal:
//  a) tampilkan foto, nama, status, spesies, gender, origin, location
//  b) tombol Favorite untuk menambah/menghapus dari favorit
//  c) SnackBar ketika ditambahkan/dihapus
//  d) icon Favorite berubah sesuai status favorit
//
// Data diambil dari endpoint DETAIL: /character/{id}
import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/character.dart';
import '../services/favorite_service.dart';
import '../widgets/status_label.dart';

class DetailScreen extends StatefulWidget {
  final int characterId; // dikirim dari halaman list

  const DetailScreen({super.key, required this.characterId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Character? character; // nullable: belum ada saat halaman baru dibuka
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final data = await ApiService.getCharacterDetail(widget.characterId);
      setState(() {
        character = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat detail karakter.';
        isLoading = false;
      });
    }
  }

  void _toggleFavorite() async {
    if (character == null) return;
    final bool nowFavorite = await FavoriteService.toggle(character!);
    if (!mounted) return;
    // (c) SnackBar sesuai aksi
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowFavorite
              ? '${character!.name} ditambahkan ke favorit'
              : '${character!.name} dihapus dari favorit',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character?.name ?? 'Detail'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        actions: [
          // (d) ICON BERUBAH SESUAI STATUS FAVORIT
          // ValueListenableBuilder mendengarkan FavoriteService.favorites,
          // jadi ikon otomatis ♡ / ♥ setiap kali daftar favorit berubah.
          if (character != null)
            ValueListenableBuilder<List<Character>>(
              valueListenable: FavoriteService.favorites,
              builder: (context, favorites, _) {
                final bool isFav = favorites.any(
                  (f) => f.id == character!.id,
                );
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                  onPressed: _toggleFavorite,
                );
              },
            ),
        ],
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

    final c = character!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ---------- FOTO ----------
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              c.image,
              width: 220,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 220,
                height: 220,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, size: 64),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ---------- NAMA ----------
          Text(
            c.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          StatusLabel(status: c.status),
          const SizedBox(height: 16),
          // ---------- INFO LAINNYA ----------
          // Card berisi baris-baris info. ListTile dipakai agar rapi:
          // leading = ikon, title = label, subtitle = nilai
          Card(
            color: Colors.white,
            child: Column(
              children: [
                _infoTile(Icons.monitor_heart, 'Status', c.status),
                _infoTile(Icons.pets, 'Species', c.species),
                _infoTile(Icons.wc, 'Gender', c.gender),
                _infoTile(Icons.public, 'Origin', c.origin),
                _infoTile(Icons.location_on, 'Location', c.location),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}
