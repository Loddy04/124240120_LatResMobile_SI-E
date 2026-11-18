// =============================================================
// MODEL CHARACTER (Modul V - Model + fromJson)
// =============================================================
// Contoh JSON satu karakter (https://rickandmortyapi.com/api/character/1):
// {
//   "id": 1,
//   "name": "Rick Sanchez",
//   "status": "Alive",            -> Alive / Dead / unknown
//   "species": "Human",
//   "gender": "Male",
//   "origin":   {"name": "Earth (C-137)",    "url": "..."},   <- OBJECT
//   "location": {"name": "Citadel of Ricks", "url": "..."},   <- OBJECT
//   "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
//   "episode": ["https://.../episode/1", ...]
// }
//
// PERHATIKAN: "origin" & "location" berupa OBJECT (nested), bukan String.
// Cara mengambilnya: json['origin']['name']
//
// Model ini punya fromJson DAN toJson:
//  - fromJson : Map (dari API / SharedPreferences) -> object Character
//  - toJson   : object Character -> Map (untuk disimpan ke SharedPreferences)
// SharedPreferences hanya bisa menyimpan tipe sederhana (String, int, bool,
// List<String>), jadi object harus diubah dulu ke Map lalu ke String JSON.
class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String origin;
  final String location;
  final String image;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'] ?? '-',
      status: json['status'] ?? 'unknown',
      species: json['species'] ?? '-',
      gender: json['gender'] ?? '-',
      // Dari API: origin adalah Map -> ambil ['name'].
      // Dari SharedPreferences (hasil toJson kita): origin sudah String.
      // "is Map" mengecek tipe datanya supaya fromJson bisa dipakai
      // untuk KEDUA sumber data tersebut.
      origin: json['origin'] is Map
          ? json['origin']['name'] ?? '-'
          : json['origin'] ?? '-',
      location: json['location'] is Map
          ? json['location']['name'] ?? '-'
          : json['location'] ?? '-',
      image: json['image'] ?? '',
    );
  }

  // Kebalikan dari fromJson. Dipakai saat menyimpan favorit ke SP.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'gender': gender,
      'origin': origin, // disimpan sebagai String biasa
      'location': location,
      'image': image,
    };
  }
}
