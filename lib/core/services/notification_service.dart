import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:kaza_takip/core/constants/app_constants.dart';

/// Namaz vakti hatırlatıcı servisi.
///
/// adhan ile konuma göre vakitleri hesaplar, flutter_local_notifications ile
/// her vakit için zamanlı yerel bildirim planlar. Tamamen cihazda çalışır —
/// sunucu/ağ gerektirmez (ücretsiz & offline).
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final SharedPreferences _prefs;

  bool _initialized = false;

  NotificationService(this._prefs);

  // Vakit anahtarları → Türkçe ad (bildirim metni için)
  static const Map<String, String> _vakitNames = {
    'fajr': 'Sabah',
    'dhuhr': 'Öğle',
    'asr': 'İkindi',
    'maghrib': 'Akşam',
    'isha': 'Yatsı',
  };

  bool get isEnabled =>
      _prefs.getBool(AppConstants.prefNotificationsEnabled) ?? false;

  // ── Başlatma ────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(await _deviceTimeZone()));
    } catch (_) {
      // Bölge çözülemezse UTC'de kal.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<String> _deviceTimeZone() async {
    // timezone paketi cihaz bölgesini doğrudan vermez; varsayılan İstanbul.
    return 'Europe/Istanbul';
  }

  // ── İzinler ─────────────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted =
        await android?.requestNotificationsPermission() ?? true;
    await android?.requestExactAlarmsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidGranted || iosGranted;
  }

  // ── Aç / Kapa ───────────────────────────────────────────────────────────────

  Future<bool> enable() async {
    final granted = await requestPermissions();
    if (!granted) return false;
    await _prefs.setBool(AppConstants.prefNotificationsEnabled, true);
    await rescheduleAll();
    return true;
  }

  Future<void> disable() async {
    await _prefs.setBool(AppConstants.prefNotificationsEnabled, false);
    await _plugin.cancelAll();
  }

  // ── Konum ───────────────────────────────────────────────────────────────────

  Future<Coordinates> _resolveCoordinates() async {
    // Önbellekteki konum varsa kullan.
    final cachedLat = _prefs.getDouble(AppConstants.prefLatitude);
    final cachedLng = _prefs.getDouble(AppConstants.prefLongitude);
    if (cachedLat != null && cachedLng != null) {
      return Coordinates(cachedLat, cachedLng);
    }

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        await _prefs.setDouble(AppConstants.prefLatitude, pos.latitude);
        await _prefs.setDouble(AppConstants.prefLongitude, pos.longitude);
        return Coordinates(pos.latitude, pos.longitude);
      }
    } catch (_) {
      // Konum alınamazsa varsayılana düş.
    }
    return Coordinates(
        AppConstants.defaultLatitude, AppConstants.defaultLongitude);
  }

  // ── Planlama ────────────────────────────────────────────────────────────────

  /// Önümüzdeki [days] gün için tüm vakit hatırlatıcılarını yeniden kurar.
  Future<void> rescheduleAll({int days = 7}) async {
    await init();
    if (!isEnabled) return;

    await _plugin.cancelAll();
    final coords = await _resolveCoordinates();
    final params = CalculationMethod.turkey.getParameters();
    final now = DateTime.now();

    for (var d = 0; d < days; d++) {
      final date = now.add(Duration(days: d));
      final times = PrayerTimes(
        coords,
        DateComponents.from(date),
        params,
      );

      final schedule = <String, DateTime>{
        'fajr': times.fajr,
        'dhuhr': times.dhuhr,
        'asr': times.asr,
        'maghrib': times.maghrib,
        'isha': times.isha,
      };

      var vakitIndex = 0;
      for (final entry in schedule.entries) {
        final when = entry.value;
        if (when.isAfter(now)) {
          await _scheduleOne(
            id: d * 10 + vakitIndex,
            vakitKey: entry.key,
            when: when,
          );
        }
        vakitIndex++;
      }
    }
  }

  Future<void> _scheduleOne({
    required int id,
    required String vakitKey,
    required DateTime when,
  }) async {
    final name = _vakitNames[vakitKey] ?? 'Namaz';
    final tzTime = tz.TZDateTime.from(when, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_reminders',
        'Namaz Vakti Hatırlatıcıları',
        channelDescription:
            'Her namaz vaktinde kaza namazı hatırlatması',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      '$name Vakti 🕌',
      '$name vakti girdi. Bugünkü kaza namazını kılmayı unutma 🤲',
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
