// =============================================================
// MODEL DATA DARI API (Modul V - bagian "Menggunakan Model")
// =============================================================
// Class ini merepresentasikan SATU data (news / blog / report)
// yang didapat dari API Spaceflight News.
//
// Contoh JSON dari API:
// {
//   "id": 40887,
//   "title": "PLD Space Investor Selects ...",
//   "authors": [{"name": "European Spaceflight", "socials": null}],
//   "url": "https://europeanspaceflight.com/...",
//   "image_url": "https://.../gambar.webp",
//   "news_site": "European Spaceflight",
//   "summary": "Japanese satellite manufacturer ...",
//   "published_at": "2026-11-18T07:25:17Z",
//   ...
// }
//
// Dengan model, kita mengakses data pakai notasi titik (item.title)
// yang lebih aman daripada notasi key (item['title']).
class SpaceItem {
  final int id;
  final String title;
  final String author; // diambil dari "news_site" (lihat penjelasan di fromJson)
  final String imageUrl;
  final String url; // link ke situs resmi berita
  final String summary;
  final String publishedAt;

  SpaceItem({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.url,
    required this.summary,
    required this.publishedAt,
  });

  // factory constructor: membuat instance SpaceItem dari Map JSON.
  // Operator "??" dipakai sebagai nilai cadangan kalau datanya null,
  // supaya aplikasi tidak crash ketika ada field yang kosong.
  factory SpaceItem.fromJson(Map<String, dynamic> json) {
    return SpaceItem(
      id: json['id'],
      title: json['title'] ?? '-',
      // Di contoh soal, author yang tampil adalah "NASA", "Spaceflight Now", dll.
      // Nilai tersebut ada di field "news_site", jadi itu yang kita pakai
      // sebagai author (sekaligus dasar fitur filter).
      author: json['news_site'] ?? 'Unknown',
      imageUrl: json['image_url'] ?? '',
      url: json['url'] ?? '',
      summary: json['summary'] ?? '',
      publishedAt: json['published_at'] ?? '',
    );
  }
}
