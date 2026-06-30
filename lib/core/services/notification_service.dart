import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:kaza_takip/core/constants/app_constants.dart';
import 'package:kaza_takip/core/data/spiritual_content.dart';
import 'package:kaza_takip/core/utils/daily_seed.dart';

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

  // ── Manevi (AI-destekli) bildirim tercihleri ────────────────────────────────

  bool get isSpiritualEnabled =>
      _prefs.getBool(AppConstants.prefSpiritualNotificationsEnabled) ?? false;

  /// 1 = sadece sabah, 2 = sabah + akşam. Varsayılan: 2.
  int get spiritualFrequency =>
      _prefs.getInt(AppConstants.prefSpiritualNotificationFrequency) ?? 2;

  Future<void> setSpiritualFrequency(int value) =>
      _prefs.setInt(
          AppConstants.prefSpiritualNotificationFrequency, value.clamp(1, 2));

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
    // Sadece namaz vakti bildirimlerini iptal et (id < 1000 aralığı).
    for (var d = 0; d < 7; d++) {
      for (var v = 0; v < 5; v++) {
        await _plugin.cancel(d * 10 + v);
      }
    }
  }

  // ── Manevi bildirim aç/kapa ─────────────────────────────────────────────────

  Future<bool> enableSpiritual() async {
    final granted = await requestPermissions();
    if (!granted) return false;
    await _prefs.setBool(
        AppConstants.prefSpiritualNotificationsEnabled, true);
    await rescheduleSpiritual();
    return true;
  }

  Future<void> disableSpiritual() async {
    await _prefs.setBool(
        AppConstants.prefSpiritualNotificationsEnabled, false);
    // id aralığı: 1000-2999 (14 gün × 2 slot = 28 bildirim).
    for (var i = 1000; i < 3000; i++) {
      await _plugin.cancel(i);
    }
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
  /// Manevi bildirimler aktifse onları da yeniden planlar.
  Future<void> rescheduleAll({int days = 7}) async {
    await init();

    if (isEnabled) {
      // Sadece namaz id aralığını temizle (0..69).
      for (var d = 0; d < days; d++) {
        for (var v = 0; v < 5; v++) {
          await _plugin.cancel(d * 10 + v);
        }
      }

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

    if (isSpiritualEnabled) {
      await rescheduleSpiritual();
    }
  }

  // ── Manevi (AI-destekli) günlük bildirim planlayıcı ────────────────────────

  /// Sabah 09:30 (ve seçilirse akşam 21:00) için önümüzdeki [days] güne
  /// manevi mesaj zamanlar. Her güne ayet/hadis/Mevlana/Gazali/Risale
  /// kategorilerinden farklı bir parça seçilir (DailySeed deterministik).
  Future<void> rescheduleSpiritual({int days = 14}) async {
    await init();
    if (!isSpiritualEnabled) return;

    // 1000-2999 aralığını temizle.
    for (var i = 1000; i < 3000; i++) {
      await _plugin.cancel(i);
    }

    final freq = spiritualFrequency.clamp(1, 2);
    final now = DateTime.now();
    final slots = freq == 2
        ? [const _Slot(true, 9, 30), const _Slot(false, 21, 0)]
        : [const _Slot(true, 9, 30)];

    for (var d = 0; d < days; d++) {
      final date = DateTime(now.year, now.month, now.day).add(Duration(days: d));
      for (final slot in slots) {
        final when = DateTime(date.year, date.month, date.day,
            slot.hour, slot.minute);
        if (!when.isAfter(now)) continue;
        final picked = DailySeed.pickFor(day: date, morning: slot.isMorning);
        await _scheduleSpiritual(
          id: (slot.isMorning ? 1000 : 2000) + d,
          category: picked.$1,
          piece: picked.$2,
          when: when,
        );
      }
    }
  }

  Future<void> _scheduleSpiritual({
    required int id,
    required SpiritualCategory category,
    required SpiritualPiece piece,
    required DateTime when,
  }) async {
    final tzTime = tz.TZDateTime.from(when, tz.local);
    final title = _spiritualTitle(category);
    // Bildirim metni kısa olmalı — uzun alıntıyı 140 karakterde kes.
    final body = piece.text.length > 140
        ? '${piece.text.substring(0, 137)}…'
        : piece.text;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'spiritual_reminders',
        'Manevi Bildirimler',
        channelDescription:
            'Günde 1-2 kere ayet, hadis, Mevlana, Gazali veya Risale-i Nur\'dan kısa mesaj',
        importance: Importance.high,
        priority: Priority.defaultPriority,
        styleInformation: BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      '$body\n— ${piece.source}',
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  String _spiritualTitle(SpiritualCategory c) => switch (c) {
        SpiritualCategory.ayet => '✨ Günün Ayeti',
        SpiritualCategory.hadis => '📜 Hadis-i Şerif',
        SpiritualCategory.mevlana => '🌹 Hz. Mevlana\'dan',
        SpiritualCategory.gazali => '📿 İmam Gazali\'den',
        SpiritualCategory.risale => '💡 Risale-i Nur\'dan',
      };

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

class _Slot {
  final bool isMorning;
  final int hour;
  final int minute;
  const _Slot(this.isMorning, this.hour, this.minute);
}
