# Panduan Responsi Mobile (acuan: branch `main`)

Panduan ini menjelaskan **cara mengubah kode di repo ini menjadi aplikasi untuk soal baru**.
Semua contoh merujuk ke kode di branch `main` (aplikasi Spaceflight News).

Daftar isi:
1. [Konsep dasar: API, endpoint, JSON](#1-konsep-dasar-api-endpoint-json)
2. [Cara membaca JSON (analogi lemari)](#2-cara-membaca-json-analogi-lemari)
3. [Lembar kerja: isi SEBELUM ngoding](#3-lembar-kerja-isi-sebelum-ngoding)
4. [Langkah konfigurasi proyek](#4-langkah-konfigurasi-proyek)
5. [Perjalanan data: dari link API sampai tampil di layar](#5-perjalanan-data-dari-link-api-sampai-tampil-di-layar)
6. [⭐ RESEP: langkah demi langkah saat responsi](#6--resep-langkah-demi-langkah-saat-responsi)
7. [🔐 Login, Register & Logout (lengkap)](#7--login-register--logout-lengkap)
8. [🔔 Notifikasi (lengkap)](#8--notifikasi-lengkap)
9. [Referensi isi tiap file](#9-referensi-isi-tiap-file)
10. [Contoh lengkap: mengubah ke API lain](#10-contoh-lengkap-mengubah-ke-api-lain)
11. [Error yang sering muncul](#11-error-yang-sering-muncul)
12. [Branch mana yang dicontek?](#12-branch-mana-yang-dicontek)

> **Saat responsi, langsung buka [bagian 6 (RESEP)](#6--resep-langkah-demi-langkah-saat-responsi)** dan ikuti urutannya.
> Bagian 1–5 untuk memahami konsepnya.

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

### D. Daftar SEMUA endpoint di soal

Soal biasanya memberi lebih dari satu endpoint. Tulis semuanya, lalu kelompokkan:

| Endpoint | Fungsinya (list / detail / filter) | Bentuk JSON sama dengan endpoint lain? |
|---|---|---|
| | | |
| | | |
| | | |

Contoh di branch `main`:

| Endpoint | Fungsinya | Bentuk JSON |
|---|---|---|
| `/v4/articles/` | list News | sama ketiganya: `{ "results": [...] }` |
| `/v4/blogs/` | list Blog | sama |
| `/v4/reports/` | list Report | sama |
| `/v4/{menu}/{id}/` | detail | satu object `{...}` |

→ Karena bentuknya **sama**, cukup **1 model + 1 fungsi list + 1 halaman list** yang dipakai bergantian (lihat Kasus A di bagian 6).

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
| 7 | Jika pakai **notifikasi**: ikuti [bagian 8](#8--notifikasi-lengkap) (pubspec, `build.gradle.kts`, manifest, service, `main.dart`) | Jika bonus notifikasi |

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

## 5. Perjalanan data: dari link API sampai tampil di layar

### Di mana link API-nya ditulis?

**Bukan di `pubspec.yaml`.** `pubspec.yaml` hanya daftar "alat" (package) yang diunduh, misalnya `http` untuk mengambil data dari internet.

Link API ditulis di **`lib/api/api_service.dart`**:

```dart
// baris 16: potongan AWAL link (bagian yang sama untuk semua endpoint)
static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

// baris 20: link disambung saat dipakai
final response = await http.get(Uri.parse('$baseUrl/$menu/'));
```

`$baseUrl` dan `$menu` = variabel yang ditempel ke dalam teks. Nilai `menu` berasal dari tombol di Home
(`home_screen.dart` baris 48: `menu: 'articles'`). Hasilnya:

```
'$baseUrl/$menu/'
   │        └─ 'articles'
   └─ 'https://api.spaceflightnewsapi.net/v4'
=  'https://api.spaceflightnewsapi.net/v4/articles/'   ← persis link di soal
```

### Urutan kode berjalan saat user klik "News"

```
① home_screen.dart:113      klik kartu News
                            → Navigator.push(ListScreen(title: 'News', menu: 'articles'))
        ↓
② list_screen.dart:34-36    halaman List terbuka → initState() → fetchItems()
   list_screen.dart:47      fetchItems memanggil: ApiService.getList(widget.menu)
        ↓
③ api_service.dart:20       http.get('https://.../v4/articles/')   ← ke internet
   api_service.dart:24      jsonDecode(response.body)              ← teks JSON → Map/List
   api_service.dart:26      data['results']                        ← buka laci "results"
   api_service.dart:28      SpaceItem.fromJson(json) untuk tiap item
        ↓
④ space_item.dart:44-55     fromJson: json['title'] → title, json['news_site'] → author, ...
        ↓
⑤ list_screen.dart:48-51    setState(() { items = data; isLoading = false; })
                            → "data sudah datang, gambar ulang layarnya"
        ↓
⑥ list_screen.dart:152-178  ListView.builder: Text(item.title), Text(item.author), Image.network(item.imageUrl)
        ↓
   klik salah satu item
        ↓
⑦ list_screen.dart:185      Navigator.push(DetailScreen(menu: 'articles', id: item.id))
   detail_screen.dart:46    ApiService.getDetail(widget.menu, widget.id)
   api_service.dart:37      http.get('https://.../v4/articles/40887/')  → satu object → fromJson
```

**Kesimpulan:**
- **Screen** tidak pernah menyentuh link/JSON. Screen hanya memanggil `ApiService.namaFungsi(...)` dan menerima object model.
- **ApiService** yang tahu link & bentuk JSON.
- **Model** yang tahu nama-nama key JSON.
- Data dikirim antar halaman lewat **constructor**: `ListScreen(menu: ...)`, `DetailScreen(id: ...)`.

---

## 6. ⭐ RESEP: langkah demi langkah saat responsi

Ikuti berurutan. Setiap langkah menyebut **file mana yang disalin dari `main`** dan **baris mana yang diganti**.

> **Trik Find & Replace:** setelah menyalin file, tekan `Ctrl+H` di editor untuk mengganti semua kata sekaligus.
> Contoh: ganti semua `SpaceItem` → `Game`, dan `space_item.dart` → `game.dart`.

### 🗺️ Peta file: mana yang bisa langsung disalin

**🟢 SALIN UTUH**: tidak perlu diubah (kecuali catatan kecil)

| File | Ambil dari branch | Catatan |
|---|---|---|
| `lib/models/user.dart` (+ jalankan build_runner) | `main` | model akun Hive. `typeId: 0`, jangan sampai sama dengan model Hive lain |
| `lib/screens/register_screen.dart` | `main` | – |
| `lib/services/notification_service.dart` | `alternatif-sib` | lihat [bagian 8](#8--notifikasi-lengkap) |
| `android/gradle.properties` → baris `kotlin.incremental=false` | `main` | khusus laptop ini |

**🟡 SALIN, UBAH SEDIKIT**: kerangkanya tetap, ganti 1–5 baris

| File | Ambil dari branch | Yang diganti |
|---|---|---|
| `lib/screens/login_screen.dart` | `main` (dengan register) / `alternatif-sib` (tanpa register) | import & halaman tujuan setelah login ([bagian 7](#7--login-register--logout-lengkap)) |
| `lib/main.dart` | `main` | adapter, box, tema, halaman awal (Langkah 5) |
| Fungsi `_logout` | `main` (`home_screen.dart` baris 20–36) | halaman tempat tombol logout berada |
| `lib/screens/main_screen.dart` (BottomNavigationBar) | `alternatif-sib` / `alternatif-rickmorty` | daftar halaman tiap tab, label & ikon |
| `pubspec.yaml` (bagian dependencies) | `main` (+ notif dari `alternatif-sib`) | pilih package yang dipakai |
| `AndroidManifest.xml` (permission & receiver) | `main` / `alternatif-sib` | tempel di posisi yang benar |

**🔴 SALIN, UBAH ISINYA**: berbeda untuk setiap API

| File | Ambil dari branch | Yang diganti |
|---|---|---|
| `lib/models/<data_api>.dart` | `main` (`space_item.dart`) | field & `fromJson` (Langkah 3) |
| `lib/api/api_service.dart` | `main` | `baseUrl`, laci JSON, fungsi tiap endpoint (Langkah 4) |
| Halaman list / home | `main` | pemanggilan ApiService & `item.xxx` (Langkah 6–7) |
| Halaman detail | `main` | pemanggilan ApiService & `data.xxx` (Langkah 8) |
| `lib/models/favorite.dart` + halaman favorit | `main` (Hive) / `alternatif-rickmorty` (SharedPreferences) | field yang disimpan (Langkah 9) |

### Langkah 0 — Pahami endpoint (10 menit, JANGAN DILEWATI)

1. Buka setiap endpoint di browser, isi [lembar kerja bagian 3](#3-lembar-kerja-isi-sebelum-ngoding).
2. Tentukan soalmu termasuk **kasus** yang mana (boleh lebih dari satu):

| Kasus | Ciri endpoint | Cara menangani | Contoh |
|---|---|---|---|
| **A** | Beberapa endpoint, **bentuk JSON sama**, hanya beda path | 1 model, **1 fungsi dengan parameter**, 1 halaman list dipakai bergantian | `main`: `/articles`, `/blogs`, `/reports` |
| **B** | Beberapa endpoint, **isi datanya berbeda** | **1 model + 1 fungsi + 1 halaman per jenis** | `alternatif-rickmorty`: `/character` & `/episode` |
| **C** | Endpoint yang sama + **query** (`?status=alive`, `?name=rick`) | 1 fungsi dengan **parameter tambahan** | `alternatif-rickmorty`: filter status |
| **D** | Endpoint **detail** (`/{id}` atau `?id=`) | fungsi detail menerima `id` | semua branch |

### Langkah 1 — Buat proyek & konfigurasi

Ikuti [bagian 4](#4-langkah-konfigurasi-proyek). Lalu buat folder di dalam `lib/`:

```
lib/
├── api/        <- api_service.dart
├── models/     <- model API + model Hive (user, favorite)
├── screens/    <- semua halaman
└── services/   <- (opsional) notification_service.dart, favorite_service.dart
```

### Langkah 2 — Login, Register & Logout

Ikuti **[bagian 7](#7--login-register--logout-lengkap)** sampai tuntas, lalu **jalankan aplikasi dan tes login dulu**
sebelum lanjut ke API. Kalau login sudah jalan, sepertiga soal biasanya sudah aman.

### Langkah 3 — Model (salin & ubah isi)

1. Salin `lib/models/space_item.dart` → ganti nama file sesuai datanya, misal `lib/models/game.dart`.
2. `Ctrl+H`: `SpaceItem` → `Game`.
3. Ubah **daftar field** (baris 23–29) sesuai data yang diminta soal di halaman list **dan** detail.
4. Ubah **constructor** (baris 31–39) agar sama dengan daftar field.
5. Ubah **isi `fromJson`** (baris 44–56): `json['...']` diisi key dari lembar kerja.

```dart
class Game {
  final int id;               // ← field: nama bebas
  final String title;
  final String thumbnail;

  Game({required this.id, required this.title, required this.thumbnail});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'] ?? '-',          // ← key: PERSIS seperti di browser
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}
```

> **Kasus B** (data berbeda jenis): buat **satu file model per jenis**, misal `character.dart` dan `episode.dart`.

### Langkah 4 — ApiService (salin & ubah isi)

1. Salin `lib/api/api_service.dart` ke `lib/api/api_service.dart`.
2. `Ctrl+H`: `SpaceItem` → nama model-mu, `space_item.dart` → nama file model-mu.
3. Ganti **`baseUrl`** (baris 16) dengan bagian link yang sama di semua endpoint.
   - Endpoint `https://www.freetogame.com/api/games` dan `https://www.freetogame.com/api/game?id=1`
   - → `baseUrl = 'https://www.freetogame.com/api'`
4. Tulis fungsi untuk **setiap endpoint** memakai template di bawah.

**TEMPLATE fungsi LIST:**
```dart
static Future<List<NamaModel>> namaFungsi() async {
  final response = await http.get(Uri.parse('$baseUrl/PATH_ENDPOINT'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<dynamic> results = data['results'];   // JSON diawali [ → ganti: = data;
    return results.map((json) => NamaModel.fromJson(json)).toList();
  } else {
    throw Exception('Gagal memuat data');
  }
}
```

**TEMPLATE fungsi DETAIL:**
```dart
static Future<NamaModel> namaFungsiDetail(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/PATH_ENDPOINT/$id'));   // atau ?id=$id
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return NamaModel.fromJson(data);
  } else {
    throw Exception('Gagal memuat detail');
  }
}
```

**Penerapan template per kasus:**

```dart
// KASUS A — endpoint sejenis: path dikirim sebagai PARAMETER (seperti main)
static Future<List<SpaceItem>> getList(String menu) async {
  final response = await http.get(Uri.parse('$baseUrl/$menu/'));
  ...
}
// dipanggil: ApiService.getList('articles') / getList('blogs') / getList('reports')

// KASUS B — endpoint beda jenis: SATU FUNGSI PER ENDPOINT
static Future<List<Character>> getCharacters() async { ... '$baseUrl/character' ... }
static Future<List<Episode>>   getEpisodes()   async { ... '$baseUrl/episode'   ... }

// KASUS C — query filter: parameter tambahan ditempel ke link
static Future<List<Character>> getCharacters(String status) async {
  final response = await http.get(Uri.parse('$baseUrl/character?status=$status'));
  ...
}
// dipanggil: ApiService.getCharacters('alive')

// KASUS D — detail
static Future<Game> getGameDetail(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/game?id=$id'));
  ...
}
```

> **Tes cepat:** sebelum membuat halaman, pastikan link yang tersusun sama persis dengan link di soal.
> Tulis link-nya di kertas: `baseUrl` + `/` + path + `/` + id. Bandingkan huruf per huruf (termasuk `/` di akhir).

### Langkah 5 — `main.dart` (salin, ubah sedikit)

Salin `lib/main.dart`, lalu cek:

| Baris | Isi | Ubah jika |
|---|---|---|
| 8–11 | import | nama file model/halaman berbeda |
| 25–26 | `Hive.registerAdapter(...)` | adapter berbeda (nama = `NamaModel` + `Adapter`) |
| 28–29 | `Hive.openBox<...>('...')` | nama box berbeda / tidak pakai favorit Hive (hapus barisnya) |
| 51–59 | `title` & `theme` | ganti judul & warna aplikasi |
| 62 | `home: isLogin ? HomeScreen(...) : LoginScreen()` | nama halaman utamamu berbeda |

### Langkah 6 — Halaman utama

Pilih sesuai soal:

**(a) Soal punya beberapa menu (Kasus A)** → salin `lib/screens/home_screen.dart`.
Setiap kartu menu adalah satu blok `_MenuCard` (baris 46–66):
```dart
const _MenuCard(
  title: 'News',                // teks yang tampil di kartu
  menu: 'articles',             // ← PATH ENDPOINT, persis seperti di link API
  icon: Icons.newspaper,
  description: 'Deskripsi bebas...',
),
```
- Tambah menu = salin satu blok `_MenuCard`. Kurangi menu = hapus satu blok.
- `menu` inilah yang nanti ditempel ke link: `'$baseUrl/$menu/'`.

**(b) Soal langsung menampilkan list** (tanpa menu) → halaman list (Langkah 7) **dijadikan halaman utama**.
Di `main.dart` baris 62 dan `login_screen.dart` baris 68, ganti `HomeScreen(...)` dengan halaman list-mu.

**(c) Soal minta BottomNavigationBar** → salin `lib/screens/main_screen.dart` dari branch `alternatif-sib`,
lalu isi daftar `_pages` dengan halaman-halamanmu.

### Langkah 7 — Halaman list (salin & ubah)

1. Salin `lib/screens/list_screen.dart`.
2. `Ctrl+H`: `SpaceItem` → nama model-mu, `space_item.dart` → nama file model-mu.
3. Ganti baris-baris ini:

| Baris | Isi di `main` | Ganti dengan |
|---|---|---|
| 47 | `ApiService.getList(widget.menu)` | fungsi list-mu, misal `ApiService.getGames()` |
| 161 | `item.imageUrl` | field gambar di model-mu |
| 173 | `item.title` | field judul di model-mu |
| 178 | `item.author` | field lain yang diminta soal |
| 185 | `DetailScreen(menu: widget.menu, id: item.id)` | sesuaikan dengan constructor DetailScreen-mu |

4. **Filter chip** (baris 62–69 dan 119–144):
   - Soal minta filter berdasarkan field lain (misal genre)? Ganti `e.author` (baris 62 & 68) dengan `e.genre`.
   - Soal **tidak** minta filter? Hapus baris 119–144, dan ganti `filteredItems` menjadi `items` (baris 150 & 152).
   - Soal minta filter **lewat API** (Kasus C)? Lihat `character_screen.dart` di branch `alternatif-rickmorty`.

### Langkah 8 — Halaman detail (salin & ubah)

1. Salin `lib/screens/detail_screen.dart`.
2. `Ctrl+H`: `SpaceItem` → nama model-mu, `space_item.dart` → nama file model-mu.
3. Ganti baris-baris ini:

| Baris | Isi di `main` | Ganti dengan |
|---|---|---|
| 20 | `required this.menu, required this.id` | jika tidak ada menu (bukan Kasus A), cukup `required this.id` (hapus juga variabel `menu`) |
| 46 | `ApiService.getDetail(widget.menu, widget.id)` | fungsi detail-mu, misal `ApiService.getGameDetail(widget.id)` |
| 163–200 | `data.imageUrl`, `data.title`, `data.author`, `data.publishedAt`, `data.summary` | field yang **wajib** tampil menurut soal. Tambah `Text(data.xxx)` jika perlu |
| 76–82 | `Favorite(...)` | field yang disimpan ke favorit (lihat Langkah 9) |
| 92 | `item!.url` | field link web (hapus fungsi `_openWeb` & tombolnya jika soal tidak minta) |

### Langkah 9 — Favorit (Hive)

1. Salin `lib/models/favorite.dart`. Ubah field-nya = data yang **ditampilkan di halaman favorit** + `id` (untuk membuka detail lagi).
2. Jalankan build_runner lagi.
3. Salin `lib/screens/favorite_screen.dart`. Ganti `fav.imageUrl` (45), `fav.title` (53), `fav.author` (57), dan `DetailScreen(...)` (79).
4. Bagian `ValueListenableBuilder` (baris 24) **jangan diubah**: itulah yang membuat daftar favorit langsung ter-update.

> Soal minta favorit di **SharedPreferences** (bukan Hive)? Lihat `favorite_service.dart` di branch `alternatif-rickmorty`.

### Langkah 10 — Endpoint tambahan (Kasus B)

Untuk setiap endpoint yang jenis datanya berbeda (misal `/episode`):

1. Buat model baru (Langkah 3).
2. Tambah fungsi baru di ApiService (Langkah 4, template LIST).
3. Buat halaman baru dari **TEMPLATE HALAMAN LIST** di bawah.
4. Sambungkan ke aplikasi: tombol/kartu di Home, tab di BottomNavigationBar, atau ikon di AppBar dengan:
   ```dart
   Navigator.push(context, MaterialPageRoute(builder: (context) => const EpisodeScreen()));
   ```

**TEMPLATE HALAMAN LIST** (ganti semua yang berhuruf BESAR):

```dart
import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/NAMA_FILE_MODEL.dart';

class NAMA_HALAMAN extends StatefulWidget {
  const NAMA_HALAMAN({super.key});

  @override
  State<NAMA_HALAMAN> createState() => _NAMA_HALAMANState();
}

class _NAMA_HALAMANState extends State<NAMA_HALAMAN> {
  List<NAMA_MODEL> items = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await ApiService.NAMA_FUNGSI();
      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JUDUL HALAMAN')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.FIELD_JUDUL),
                      subtitle: Text(item.FIELD_LAIN),
                    );
                  },
                ),
    );
  }
}
```

### Langkah 11 — Uji & cek soal

- [ ] Register → login salah (SnackBar merah) → login benar
- [ ] Tutup aplikasi tanpa logout → buka lagi → langsung masuk
- [ ] Setiap menu/endpoint menampilkan data
- [ ] Gambar rusak tidak membuat error (ada `errorBuilder`)
- [ ] Detail menampilkan **semua** field yang wajib di soal
- [ ] Favorit: tambah dari detail, muncul di halaman favorit, hapus → ter-update
- [ ] Fitur khusus soal (filter, search, buka web, dll.)
- [ ] Logout → kembali ke Login, tombol back tidak kembali ke Home
- [ ] (Bonus) Notifikasi muncul saat aksi tertentu
- [ ] Commit & push ke repo dengan nama sesuai format soal

---

## 7. 🔐 Login, Register & Logout (lengkap)

### 7.1 Konsepnya

```
REGISTER  --box.put(username, User)-->  Hive box 'users'          (local database: daftar akun)
LOGIN     --box.get(username)-------->  cocokkan password
          --prefs.setBool('isLogin')->  SharedPreferences          (sesi: sedang login atau tidak)
BUKA APP  --prefs.getBool('isLogin')->  true  -> halaman utama
                                        false -> halaman login
LOGOUT    --prefs.remove('isLogin')-->  kembali ke halaman login
```

- **Hive** = menyimpan **akun** (bisa banyak akun).
- **SharedPreferences** = menyimpan **status login** (siapa yang sedang login).

### 7.2 Pilih varian sesuai soal

| Kalimat di soal | Varian | Salin dari |
|---|---|---|
| "Login & Register", "login menggunakan akun yang telah diregister", "local database" | **V1: Register + Login** | `main` |
| "Login dengan email & password (bebas)", tidak ada register | **V2: Login saja** | `alternatif-sib` |
| V1 + favorit disimpan per user di SharedPreferences | **V1 + load favorit** | `alternatif-rickmorty` |

### 7.3 Varian V1: Register + Login (branch `main`)

**Langkah 1: `pubspec.yaml`**
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.5.6

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.13
```

**Langkah 2: salin 3 file**

| File | Ubah? |
|---|---|
| `lib/models/user.dart` | 🟢 tidak |
| `lib/screens/register_screen.dart` | 🟢 tidak |
| `lib/screens/login_screen.dart` | 🟡 baris 12 & 68 (lihat langkah 5) |

**Langkah 3: generate adapter**
```
dart run build_runner build --delete-conflicting-outputs
```
Akan muncul `lib/models/user.g.dart` yang berisi `UserAdapter`.

**Langkah 4: `main.dart`**, minimal berisi ini:
```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user.dart';
import 'screens/home_screen.dart';     // <- GANTI: halaman utamamu
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('users');            // nama box HARUS 'users' (dipakai di login & register)

  final prefs = await SharedPreferences.getInstance();
  final bool isLogin = prefs.getBool('isLogin') ?? false;
  final String username = prefs.getString('username') ?? '';

  runApp(MainApp(isLogin: isLogin, username: username));
}

class MainApp extends StatelessWidget {
  final bool isLogin;
  final String username;
  const MainApp({super.key, required this.isLogin, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLogin
          ? HomeScreen(username: username)       // <- GANTI: halaman utamamu
          : const LoginScreen(),
    );
  }
}
```

**Langkah 5: arahkan login ke halaman utamamu.** Di `login_screen.dart`:

| Baris | Isi | Ganti jika halaman utamamu berbeda |
|---|---|---|
| 12 | `import 'home_screen.dart';` | `import 'main_screen.dart';` (misalnya) |
| 68 | `HomeScreen(username: username)` | `MainScreen(username: username)` atau `const MainScreen()` |

> Halaman utama yang **menerima username** harus punya `final String username;` dan
> `required this.username` di constructor-nya (lihat `home_screen.dart` baris 16–18).

**Langkah 6: tombol logout.** Salin fungsi ini ke halaman yang punya tombol logout
(dari `home_screen.dart` baris 20–36):

```dart
// import yang dibutuhkan:
// import 'package:shared_preferences/shared_preferences.dart';
// import 'login_screen.dart';

void _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('isLogin');
  await prefs.remove('username');

  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,          // hapus semua halaman sebelumnya
    );
  }
}
```

Tombolnya bisa di mana saja:
```dart
// tombol biasa
ElevatedButton(onPressed: () => _logout(context), child: const Text('Log Out')),

// atau ikon di AppBar
AppBar(actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context))]),
```

> Kalau `_logout` ada di dalam `State` (StatefulWidget), cukup `void _logout() async {...}`,
> pakai `if (!mounted) return;` sebagai pengganti `context.mounted` (contoh: `profile_screen.dart` di `alternatif-sib`).

### 7.4 Varian V2: Login saja (branch `alternatif-sib`)

1. Salin `lib/screens/login_screen.dart` dari `alternatif-sib`. **Tidak perlu** `user.dart`, register, maupun Hive untuk akun.
2. Ganti halaman tujuan: baris 16 (import `main_screen.dart`) dan baris 66 (`const MainScreen()`).
3. Di `main.dart` cukup cek `prefs.getBool('isLogin')`.
4. Yang disimpan: `prefs.setString('email', email)` (baris 56). Logout menghapus `'isLogin'` & `'email'`.

### 7.5 Menampilkan username/email di halaman lain

**Cara 1: kirim lewat constructor** (dipakai di `main`):
```dart
// saat pindah halaman
Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(username: username)));

// di halaman tujuan
class HomeScreen extends StatelessWidget {
  final String username;
  const HomeScreen({super.key, required this.username});
  ...
  appBar: AppBar(title: Text('Hai, $username!')),
```

**Cara 2: baca langsung dari SharedPreferences** (dipakai di `profile_screen.dart` `alternatif-sib`):
```dart
String email = '-';

@override
void initState() {
  super.initState();
  _loadEmail();
}

Future<void> _loadEmail() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    email = prefs.getString('email') ?? '-';
  });
}
```

### 7.6 ⚠️ Yang WAJIB diperhatikan

| Hal | Kenapa |
|---|---|
| **Nama key SharedPreferences harus sama persis** di `main.dart`, `login_screen.dart`, dan `_logout` (`'isLogin'`, `'username'`) | Salah satu huruf beda → aplikasi selalu kembali ke login / tidak pernah logout |
| **Nama box Hive harus sama** (`'users'`) di `main.dart`, `login_screen.dart`, `register_screen.dart` | Kalau beda → error "Box not found" |
| **`typeId` setiap model Hive harus berbeda** (`User` = 0, `Favorite` = 1, model lain = 2, ...) | Kalau sama → error saat `registerAdapter` |
| **Jalankan build_runner** setiap kali membuat/mengubah model Hive | Tanpa itu `UserAdapter` tidak ada |
| Pakai `if (mounted)` / `if (context.mounted)` sebelum `Navigator` setelah `await` | Menghindari warning/error context |
| `pushReplacement` setelah login, `pushAndRemoveUntil` saat logout | Supaya tombol back tidak kembali ke halaman yang salah |

### 7.7 Kustomisasi yang sering diminta

```dart
// Username diganti email: ubah label & keyboard di TextField
decoration: InputDecoration(labelText: 'Email'),
keyboardType: TextInputType.emailAddress,

// Validasi email harus ada '@'
if (!email.contains('@')) {
  _showError('Format email tidak valid!');
  return;
}

// Password minimal 6 karakter (taruh di register)
if (password.length < 6) {
  _showError('Password minimal 6 karakter!');
  return;
}

// Tombol tampilkan/sembunyikan password
bool _obscure = true;   // variabel di dalam State
TextField(
  obscureText: _obscure,
  decoration: InputDecoration(
    suffixIcon: IconButton(
      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
      onPressed: () => setState(() => _obscure = !_obscure),
    ),
  ),
),
```

---

## 8. 🔔 Notifikasi (lengkap)

Sumber: branch `alternatif-sib` (mengikuti Modul VII). Ada **6 langkah, semuanya wajib**.
Kalau satu terlewat, biasanya build gagal atau notifikasi tidak muncul.

### Langkah N1: `pubspec.yaml`
```yaml
dependencies:
  flutter_local_notifications: ^19.0.0
  timezone: ^0.10.0
```
> Pakai versi **^19.0.0** (sama dengan modul). Versi yang lebih baru mengubah cara pemanggilan fungsinya,
> sehingga kode modul/repo ini bisa error.

### Langkah N2: `android/app/build.gradle.kts` (2 tempat)
```kotlin
android {
    ...
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true            // <- TAMBAH 1 (di dalam compileOptions)
    }
    ...
}

// <- TAMBAH 2: paling bawah file, DI LUAR blok android { }
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### Langkah N3: `android/app/src/main/AndroidManifest.xml`
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- TAMBAH: permission, DI LUAR <application> -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

    <application ...>
        <activity ...>
            ...
        </activity>

        <!-- TAMBAH: receiver, DI DALAM <application>, di bawah </activity> -->
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsReceiver"/>

        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>
</manifest>
```
> Paling aman: buka `AndroidManifest.xml` di branch `alternatif-sib` dan salin bagian bertanda `PERMISSION` & `RECEIVER NOTIFIKASI`.

### Langkah N4: salin service (🟢 utuh)
Salin `lib/services/notification_service.dart` dari `alternatif-sib`.
Opsional: ganti nama channel di baris 40–41 (`_channelId`, `_channelName`), misalnya menjadi `'app_channel'`.

### Langkah N5: panggil `init()` di `main.dart`
```dart
import 'services/notification_service.dart';      // <- TAMBAH import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ...
  await NotificationService().init();             // <- TAMBAH, SEBELUM runApp
  ...
  runApp(...);
}
```

### Langkah N6: tampilkan notifikasi
Panggil di mana saja, misalnya setelah menambah favorit:
```dart
import '../services/notification_service.dart';

NotificationService().showInstantNotification(
  id: 1,                                   // id sama -> notif lama ditimpa. Pakai id data agar unik
  title: 'Judul notifikasi',
  body: 'Isi notifikasi',
);
```

**Contoh di branch `main`:** di `detail_screen.dart` fungsi `_toggleFavorite`, setelah `favoriteBox.put(...)` (sekitar baris 83), tambahkan:
```dart
NotificationService().showInstantNotification(
  id: item!.id,
  title: 'Favorit ditambahkan ❤️',
  body: '${item!.title} masuk ke daftar favorit',
);
```

**Notifikasi terjadwal** (muncul beberapa saat lagi, tetap jalan walau aplikasi ditutup):
```dart
NotificationService().scheduleNotification(
  id: 2,
  title: 'Pengingat',
  body: 'Jangan lupa baca berita hari ini!',
  scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
);
```

### Cara mengetes
1. **Stop aplikasi, lalu jalankan ulang** (`flutter run`). Perubahan Gradle & Manifest **tidak** ikut dengan hot reload/hot restart.
2. Saat pertama dibuka, muncul pop-up izin notifikasi → pilih **Allow**.
3. Lakukan aksinya (misalnya tambah favorit), lalu tarik status bar ke bawah.

### Masalah notifikasi yang sering terjadi

| Gejala | Penyebab | Solusi |
|---|---|---|
| Build gagal: `requires core library desugaring` | Langkah N2 terlewat | Tambahkan kedua bagian desugaring |
| Notifikasi tidak muncul sama sekali | Izin ditolak, atau `init()` belum dipanggil | Cek Langkah N5; aktifkan izin di Settings → Apps → (aplikasi) → Notifications |
| Pop-up izin tidak muncul | Permission `POST_NOTIFICATIONS` tidak ada di manifest | Cek Langkah N3 |
| Error nama fungsi / parameter (`initialize`, `show`) | Versi package bukan 19 | Ubah ke `flutter_local_notifications: ^19.0.0`, lalu `flutter pub get` |
| Perubahan konfigurasi tidak berpengaruh | Hanya hot reload | Stop aplikasi, `flutter clean`, lalu `flutter run` |

---

## 9. Referensi isi tiap file

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

### Model (`lib/models/space_item.dart`)

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

### API Service (`lib/api/api_service.dart`)

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

### Halaman list (`lib/screens/list_screen.dart`)

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

### Halaman detail (`lib/screens/detail_screen.dart`)

Sama polanya dengan list (initState -> fetch -> setState). Ubah:
- Field yang ditampilkan (`data.title`, `data.summary`, dll.) sesuai yang **wajib** di soal.
- Data yang dikirim ke `Favorite(...)` saat tombol ♥ ditekan.

### Favorite (Hive)

- `lib/models/favorite.dart`: ubah field sesuai yang mau ditampilkan di halaman favorit, lalu **jalankan build_runner**.
- `lib/screens/favorite_screen.dart`: ubah nama field (`fav.title`, `fav.author`, ...).
- Bagian `ValueListenableBuilder` **jangan diubah**, karena itu yang membuat list favorit otomatis ter-update.

---

## 10. Contoh lengkap: mengubah ke API lain

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

## 11. Error yang sering muncul

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

## 12. Branch mana yang dicontek?

| Ciri soal | Branch |
|---|---|
| Register akun + menu di Home + filter chip (di sisi aplikasi) + tombol buka web + favorit Hive | `main` |
| BottomNavigationBar + login tanpa register + library Hive + halaman profil + notifikasi | `alternatif-sib` |
| BottomNavigationBar + favorit di **SharedPreferences** + hapus dengan swipe + search + filter lewat API + pagination | `alternatif-rickmorty` |
