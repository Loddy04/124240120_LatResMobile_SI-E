// =============================================================
// NOTIFICATION SERVICE (Modul VII - Contoh Program 7.4) [BONUS]
// =============================================================
// Mengelola semua fungsi notifikasi lokal.
//
// CHECKLIST SETUP NOTIFIKASI (kalau salah satu lupa, notif tidak jalan):
// 1. pubspec.yaml   : flutter_local_notifications: ^19.0.0
//                     timezone: ^0.10.0
// 2. android/app/build.gradle.kts :
//      - di dalam compileOptions { }: isCoreLibraryDesugaringEnabled = true
//      - di luar android { }       : dependencies {
//            coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }
// 3. AndroidManifest.xml : permission POST_NOTIFICATIONS (+ receiver untuk
//                          scheduled notification)
// 4. main.dart      : await NotificationService().init();  sebelum runApp
// 5. Panggil         : NotificationService().showInstantNotification(...)
//
// Memakai SINGLETON PATTERN: hanya ada SATU object NotificationService
// di seluruh aplikasi. Setiap kali kita menulis NotificationService(),
// yang dikembalikan selalu object yang sama (_instance).
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // ---------- Singleton pattern ----------
  // _instance dibuat sekali saja (static final)
  static final NotificationService _instance = NotificationService._internal();
  // factory constructor -> selalu mengembalikan _instance yang sama
  factory NotificationService() => _instance;
  // constructor private (diawali _) -> tidak bisa dipanggil dari luar file
  NotificationService._internal();

  // Plugin utama dari package flutter_local_notifications
  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  // ID & nama channel. Android 8+ mewajibkan setiap notifikasi
  // masuk ke sebuah "channel" (kategori notif di pengaturan HP).
  static const String _channelId = 'hydra_channel';
  static const String _channelName = 'Hydra Games Notifications';

  // ---------------------------------------------------------
  // init(): konfigurasi awal. Dipanggil SEKALI di main.dart.
  // ---------------------------------------------------------
  Future<void> init() async {
    // 1. Inisialisasi timezone (dibutuhkan untuk scheduled notification)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // 2. Konfigurasi Android: ikon notifikasi memakai ikon aplikasi
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await notificationPlugin.initialize(initSettings);

    // 3. Minta izin notifikasi ke user (muncul pop-up di Android 13+)
    //    lalu buat channel-nya
    final androidPlatform = notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlatform?.requestNotificationsPermission();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifikasi saat game ditambahkan ke library',
      importance: Importance.high, // high = muncul sebagai pop-up (heads-up)
    );
    await androidPlatform?.createNotificationChannel(channel);
  }

  // Detail tampilan notifikasi Android (dipakai ulang oleh 2 fungsi di bawah)
  NotificationDetails get _notifDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

  // ---------------------------------------------------------
  // IMMEDIATE notification: langsung muncul saat dipanggil.
  // DIPAKAI di aplikasi ini (saat game ditambahkan ke library).
  // ---------------------------------------------------------
  // id: kalau id sama, notif lama akan DITIMPA. Kita pakai id game
  // supaya tiap game punya notifikasi sendiri.
  Future<void> showInstantNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    await notificationPlugin.show(id, title, body, _notifDetails);
  }

  // ---------------------------------------------------------
  // SCHEDULED notification: muncul di waktu tertentu, tetap jalan
  // walau aplikasi ditutup.
  // TIDAK dipakai di aplikasi ini, disertakan sebagai CONTOH dari
  // Modul VII, siapa tahu soal responsi memintanya. Cara pakai:
  //   NotificationService().scheduleNotification(
  //     id: 1, title: 'Reminder', body: 'Main game yuk!',
  //     scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
  //   );
  // ---------------------------------------------------------
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      // TZDateTime dibuat langsung dari komponen waktu agar tidak
      // salah konversi zona waktu
      tz.TZDateTime(
        tz.local,
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
      ),
      _notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
