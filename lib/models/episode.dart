// =============================================================
// MODEL EPISODE
// =============================================================
// Contoh JSON (https://rickandmortyapi.com/api/episode):
// {
//   "id": 1,
//   "name": "Pilot",
//   "air_date": "December 2, 2013",
//   "episode": "S01E01",
//   ...
// }
class Episode {
  final int id;
  final String name;
  final String airDate;
  final String code; // contoh: "S01E01"

  Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.code,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      name: json['name'] ?? '-',
      // key di JSON memakai underscore: "air_date"
      airDate: json['air_date'] ?? '-',
      code: json['episode'] ?? '',
    );
  }
}
