// =============================================================
// MODEL USER UNTUK HIVE (Modul VI)
// =============================================================
// Menyimpan akun hasil Register ke database lokal Hive.
// Nanti saat Login, username & password dicocokkan dengan data di sini.
import 'package:hive/hive.dart';

// "part" menghubungkan file ini dengan file hasil generate build_runner.
// Jalankan: dart run build_runner build --delete-conflicting-outputs
part 'user.g.dart';

// typeId adalah identitas class di Hive. Setiap class yang disimpan
// di Hive WAJIB punya typeId yang berbeda (User = 0, Favorite = 1).
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String password;

  User({required this.username, required this.password});
}
