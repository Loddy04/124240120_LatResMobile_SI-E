# Panduan Responsi Mobile (acuan: branch `main`)

Panduan ini menjelaskan **cara mengubah kode di repo ini menjadi aplikasi untuk soal baru**.
Semua contoh merujuk ke kode di branch `main` (aplikasi Spaceflight News).

Daftar isi:
1. [Konsep dasar: API, endpoint, JSON](#1-konsep-dasar-api-endpoint-json)
2. [Cara membaca JSON (analogi lemari)](#2-cara-membaca-json-analogi-lemari)
3. [Lembar kerja: isi SEBELUM ngoding](#3-lembar-kerja-isi-sebelum-ngoding)
4. [Langkah konfigurasi proyek](#4-langkah-konfigurasi-proyek)
5. [Langkah menulis kode (file per file)](#5-langkah-menulis-kode-file-per-file)
6. [Contoh lengkap: mengubah ke API lain](#6-contoh-lengkap-mengubah-ke-api-lain)
7. [Error yang sering muncul](#7-error-yang-sering-muncul)
8. [Branch mana yang dicontek?](#8-branch-mana-yang-dicontek)

---

## 1. Konsep dasar: API, endpoint, JSON

- Aplikasi kita **tidak punya data sendiri**. Semua data (berita, game, karakter) diambil dari server orang lain lewat internet.
- **API** = layanan server yang memberikan data.
- **Endpoint** = alamat URL untuk meminta data tertentu. Biasanya ada 2 jenis:

| Jenis | Isinya | Contoh di `main` |
|---|---|---|
| Endpoint **list** | banyak data | `https://api.spaceflightnewsapi.net/v4/articles/` |
| Endpoint **detail** | satu data (berdasarkan id) | `https://api.spaceflightnewsapi.net/v4/articles/40887/` |

- **JSON** = format teks yang dikirim server. Bisa dilihat dengan membuka endpoint di browser.

Tugas aplikasi kita selalu sama:
```
ambil JSON dari endpoint  ->  ubah jadi object Dart  ->  tampilkan di layar
```

---

## 2. Cara membaca JSON (analogi lemari)

JSON hanya punya **2 jenis wadah**:

| Simbol | Bayangkan sebagai | Cara mengambil isinya di Dart |
|---|---|---|
| `{ ... }` | **lemari dengan laci berlabel** | sebut label lacinya: `data['results']` |
| `[ ... ]` | **tumpukan kertas bernomor** (mulai dari 0) | sebut nomornya: `data[0]`, atau diulang satu per satu pakai `.map(...)` |

Contoh JSON dari endpoint list Spaceflight (dipotong):

```json
{
  "count": 36936,
  "results": [
    {
      "id": 40887,
      "title": "PLD Space Investor Selects MIURA 5",
      "news_site": "European Spaceflight",
      "image_url": "https://.../gambar.webp"
    },
    {
      "id": 40886,
      "title": "Judul berita kedua"
    }
  ]
}
```

Baca dari **luar ke dalam**:

```
{                                  <- LEMARI
  "count": 36936,                  <- laci "count" berisi angka
  "results": [                     <- laci "results" berisi TUMPUKAN KERTAS
    {  "id": 40887, ...  },        <- kertas nomor 0  (juga sebuah lemari kecil)
    {  "id": 40886, ...  }         <- kertas nomor 1
  ]
}
```

Jadi untuk mengambil judul berita pertama:

```
data['results']            -> buka laci "results"        -> dapat tumpukan kertas
data['results'][0]         -> ambil kertas nomor 0       -> dapat lemari kecil
data['results'][0]['title']-> buka laci "title"          -> "PLD Space Investor Selects MIURA 5"
```

> Tips: di Chrome, centang **"Pretty-print"** di atas halaman JSON supaya tampil rapi.

---

## 3. Lembar kerja: isi SEBELUM ngoding

Buka endpoint soal di browser, lalu isi tabel ini (5 menit). Hasilnya langsung dipakai di kode.

### A. Bentuk JSON endpoint LIST
- [ ] Karakter pertama `{` atau `[` ? → ________
- [ ] Jika `{`, daftar datanya ada di laci apa? → `data['________']`

### B. URL detail
- [ ] Formatnya `/endpoint/{id}` atau `/endpoint?id={id}` ? → ________

### C. Nama key untuk setiap data yang diminta soal

| Soal minta | Nama key di JSON (salin PERSIS) | Isinya `{ }`? |
|---|---|---|
| id | | |
| judul / nama | | |
| gambar | | |
| author / genre / dll. | | |
| tanggal | | |
| deskripsi | | |

### Hasil lembar kerja untuk API di branch `main` (sebagai contoh)

| | Jawaban |
|---|---|
| Karakter pertama | `{` |
| Daftar ada di | `data['results']` |
| URL detail | `/v4/{menu}/{id}/` |
| judul | `title` |
| gambar | `image_url` |
| author | `news_site` |
| tanggal | `published_at` |
| deskripsi | `summary` |
| link web | `url` |

---

## 4. Langkah konfigurasi proyek

| No | Langkah | Wajib? |
|---|---|---|
| 1 | Buat proyek: `flutter create nama_proyek` | Ya |
| 2 | Salin `dependencies` & `dev_dependencies` dari `pubspec.yaml` (ambil yang dipakai saja), lalu `flutter pub get` | Ya |
| 3 | `android/gradle.properties`: tambahkan `kotlin.incremental=false` | Ya (khusus laptop ini, proyek di drive D:) |
| 4 | `AndroidManifest.xml`: tambahkan `<uses-permission android:name="android.permission.INTERNET"/>` | Disarankan |
| 5 | Jika pakai **url_launcher**: salin blok `<queries>` https dari `AndroidManifest.xml` | Jika ada tombol buka web |
| 6 | Jika pakai **Hive**: setelah menulis model, jalankan `dart run build_runner build --delete-conflicting-outputs` | Jika pakai Hive |
| 7 | Jika pakai **notifikasi**: lihat branch `alternatif-sib` (`build.gradle.kts` + manifest) | Jika bonus notifikasi |

Package di `main`:

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  http: ^1.6.0
  shared_preferences: ^2.5.6
  url_launcher: ^6.3.3

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.13
```

> Jalankan proyek kosong sekali di emulator **sebelum** menyalin kode, untuk memastikan konfigurasinya benar.

---

## 5. Langkah menulis kode (file per file)

Urutan pengerjaan dan status setiap file:

| Urutan | File di `main` | Status | Yang diubah |
|---|---|---|---|
| 1 | `lib/models/user.dart` | **Salin utuh** | - |
| 2 | `lib/screens/register_screen.dart` | **Salin utuh** | - |
| 3 | `lib/screens/login_screen.dart` | Salin, ubah sedikit | halaman tujuan setelah login |
| 4 | `lib/main.dart` | Salin, ubah sedikit | adapter & box Hive, tema, halaman awal |
| 5 | `lib/models/space_item.dart` | **Salin & ubah isi** | nama class, field, `fromJson` |
| 6 | `lib/api/api_service.dart` | **Salin & ubah isi** | `baseUrl`, laci `results`, URL detail |
| 7 | `lib/screens/list_screen.dart` | Salin & ubah | nama field yang ditampilkan |
| 8 | `lib/screens/detail_screen.dart` | Salin & ubah | field yang ditampilkan |
| 9 | `lib/models/favorite.dart` | Salin & ubah | field yang disimpan |
| 10 | `lib/screens/favorite_screen.dart` | Salin & ubah | field yang ditampilkan |

> Semua import di repo ini **relatif** (`'../models/user.dart'`), jadi aman disalin ke proyek dengan nama apa pun.

### Langkah 5: Model (`lib/models/space_item.dart`)

Model = "penerjemah" dari nama key JSON ke nama variabel kita.

```dart
class SpaceItem {                 // <- ganti nama class (misal: Game, Character)
  final int id;
  final String title;             // <- daftar field: sesuai yang diminta soal
  final String author;
  final String imageUrl;
  ...

  factory SpaceItem.fromJson(Map<String, dynamic> json) {
    return SpaceItem(
      id: json['id'],
      title: json['title'] ?? '-',          // json['NAMA KEY DARI LEMBAR KERJA']
      author: json['news_site'] ?? '-',
      imageUrl: json['image_url'] ?? '',
      ...
    );
  }
}
```

Aturan:
- Kiri (`title:`) = nama variabel kita, **bebas**.
- Kanan (`json['...']`) = nama key JSON, **harus persis** (huruf besar/kecil & underscore).
- `?? '-'` = nilai cadangan jika datanya kosong (null), supaya tidak crash.
- Jika isinya `{ }` (object di dalam object), masuk 2 tingkat: `json['origin']['name']`.

### Langkah 6: API Service (`lib/api/api_service.dart`)

Hanya **3 tempat** yang berubah. Ditandai dengan `<- UBAH`:

```dart
class ApiService {
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';   // <- UBAH 1

  static Future<List<SpaceItem>> getList(String menu) async {
    final response = await http.get(Uri.parse('$baseUrl/$menu/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];                       // <- UBAH 2
      return results.map((json) => SpaceItem.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data');
    }
  }

  static Future<SpaceItem> getDetail(String menu, int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$menu/$id/'));    // <- UBAH 3
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SpaceItem.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail');
    }
  }
}
```

| | Bentuk JSON | Tulis |
|---|---|---|
| UBAH 2 | diawali `{`, daftar di laci `results` | `final List<dynamic> results = data['results'];` |
| UBAH 2 | diawali `[` (langsung daftar) | `final List<dynamic> results = data;` |
| UBAH 3 | detail pakai path | `'$baseUrl/game/$id'` |
| UBAH 3 | detail pakai query | `'$baseUrl/game?id=$id'` |

### Langkah 7: Halaman list (`lib/screens/list_screen.dart`)

Kerangkanya **jangan diubah** (ini pola wajib):

```
1. variabel : items, isLoading, errorMessage
2. initState: panggil fetchItems()
3. fetchItems: try { items = await ApiService.getList(...) } catch { errorMessage }
               lalu setState(...)  <- supaya layar digambar ulang
4. build    : isLoading -> CircularProgressIndicator
              error     -> pesan error + tombol Coba Lagi
              selain itu-> ListView.builder
```

Yang diubah hanya **nama field** di dalam `ListView.builder`:

```dart
leading: Image.network(item.imageUrl, ...),   // item.<field gambar>
title: Text(item.title),                      // item.<field judul>
subtitle: Text(item.author),                  // item.<field lain yang diminta>
```

### Langkah 8: Halaman detail (`lib/screens/detail_screen.dart`)

Sama polanya dengan list (initState -> fetch -> setState). Ubah:
- Field yang ditampilkan (`data.title`, `data.summary`, dll.) sesuai yang **wajib** di soal.
- Data yang dikirim ke `Favorite(...)` saat tombol ♥ ditekan.

### Langkah 9 & 10: Favorite (Hive)

- `lib/models/favorite.dart`: ubah field sesuai yang mau ditampilkan di halaman favorit, lalu **jalankan build_runner**.
- `lib/screens/favorite_screen.dart`: ubah nama field (`fav.title`, `fav.author`, ...).
- Bagian `ValueListenableBuilder` **jangan diubah**, karena itu yang membuat list favorit otomatis ter-update.

---

## 6. Contoh lengkap: mengubah ke API lain

Misal soal memakai **FreeToGame**: `https://www.freetogame.com/api/games`

**Lembar kerja:**

| | Jawaban |
|---|---|
| Karakter pertama | `[` (langsung daftar) |
| Daftar ada di | langsung `data` |
| URL detail | `https://www.freetogame.com/api/game?id={id}` |
| judul | `title` |
| gambar | `thumbnail` |
| genre | `genre` |
| platform | `platform` |

**Model:**

```dart
class Game {
  final int id;
  final String title;
  final String thumbnail;
  final String genre;
  final String platform;

  Game({required this.id, required this.title, required this.thumbnail,
        required this.genre, required this.platform});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'] ?? '-',
      thumbnail: json['thumbnail'] ?? '',
      genre: json['genre'] ?? '-',
      platform: json['platform'] ?? '-',
    );
  }
}
```

**API Service** (perhatikan 3 tempat yang berubah):

```dart
static const String baseUrl = 'https://www.freetogame.com/api';          // UBAH 1

static Future<List<Game>> getGames() async {
  final response = await http.get(Uri.parse('$baseUrl/games'));
  if (response.statusCode == 200) {
    final List<dynamic> results = jsonDecode(response.body);              // UBAH 2: langsung list
    return results.map((json) => Game.fromJson(json)).toList();
  } else {
    throw Exception('Gagal memuat game');
  }
}

static Future<Game> getGameDetail(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/game?id=$id'));    // UBAH 3: pakai ?id=
  ...
}
```

**Halaman list**: ganti `item.author` menjadi `item.genre` / `item.platform`, dan `item.imageUrl` menjadi `item.thumbnail`.

Selesai. **Kerangka kodenya tidak berubah sama sekali.**

---

## 7. Error yang sering muncul

| Pesan error / gejala | Penyebab | Solusi |
|---|---|---|
| `type 'String' is not a subtype of type 'int' of 'index'` | JSON diawali `[` tapi kode memakai `data['results']` (daftar hanya bisa diambil pakai nomor, bukan nama laci) | Ganti jadi `final List<dynamic> results = data;` |
| `type '_Map<String, dynamic>' is not a subtype of type 'List<dynamic>'` | JSON diawali `{` tapi kode langsung menganggap list | Tambahkan `data['nama_laci']` |
| `Null is not a subtype of type 'String'` | Nama key salah ketik, atau datanya memang kosong | Cek ejaan key di browser, tambahkan `?? '-'` |
| Teks tampil `{name: Earth, url: ...}` | Key berisi object `{ }` | Masuk 2 tingkat: `json['origin']['name']` |
| `UserAdapter isn't defined` / `.g.dart` tidak ada | Belum menjalankan build_runner | `dart run build_runner build --delete-conflicting-outputs` |
| `Could not close incremental caches` | Proyek di drive D:, cache di C: | `kotlin.incremental=false` di `android/gradle.properties` |
| Gambar tidak muncul / kotak merah | URL gambar rusak | Pastikan `Image.network` punya `errorBuilder` |
| Data tidak muncul, layar tetap loading | Lupa `setState` atau lupa `isLoading = false` | Cek fungsi fetch |
| Tombol buka web diam saja | Lupa `<queries>` di manifest | Salin dari `AndroidManifest.xml` branch `main` |

---

## 8. Branch mana yang dicontek?

| Ciri soal | Branch |
|---|---|
| Register akun + menu di Home + filter chip (di sisi aplikasi) + tombol buka web + favorit Hive | `main` |
| BottomNavigationBar + login tanpa register + library Hive + halaman profil + notifikasi | `alternatif-sib` |
| BottomNavigationBar + favorit di **SharedPreferences** + hapus dengan swipe + search + filter lewat API + pagination | `alternatif-rickmorty` |
