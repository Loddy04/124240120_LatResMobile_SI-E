// =============================================================
// EPISODE SCREEN
// =============================================================
// Soal: Halaman Episode -> list episode (nama, air_date).
//
// Di sini dipakai FutureBuilder sebagai ALTERNATIF dari pola
// initState + setState (yang dipakai di halaman lain).
// FutureBuilder otomatis menangani 3 keadaan:
//   - snapshot.connectionState == waiting -> loading
//   - snapshot.hasError                   -> error
//   - snapshot.hasData                    -> data siap
// Cocok untuk halaman yang hanya MENAMPILKAN data (tanpa interaksi).
import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/episode.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  // Future disimpan di variabel & dibuat di initState.
  // JANGAN memanggil ApiService.getEpisodes() langsung di dalam build(),
  // karena build() bisa dipanggil berkali-kali -> request API berulang.
  late Future<List<Episode>> _episodesFuture;

  @override
  void initState() {
    super.initState();
    _episodesFuture = ApiService.getEpisodes();
  }

  // Dipakai tombol "Coba Lagi" saat error
  void _retry() {
    setState(() {
      _episodesFuture = ApiService.getEpisodes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Episode>>(
      future: _episodesFuture,
      builder: (context, snapshot) {
        // 1. Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Gagal memuat episode.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _retry,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        // 3. Data siap. "?? []" untuk jaga-jaga jika data null.
        final episodes = snapshot.data ?? [];

        // ListView.separated: seperti builder, tapi ada garis pemisah
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.all(12),
          child: ListView.separated(
            itemCount: episodes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ep = episodes[index];
              return ListTile(
                // Kode episode (S01E01) di kiri
                leading: Text(
                  ep.code,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Nama episode (font monospace seperti contoh soal)
                title: Text(
                  ep.name,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                // Tanggal tayang
                subtitle: Text(ep.airDate),
              );
            },
          ),
        );
      },
    );
  }
}
