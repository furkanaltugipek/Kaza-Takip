import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kaza_takip/core/constants/app_constants.dart';
import 'package:kaza_takip/data/datasources/prayer_times_local_data_source.dart';
import 'package:kaza_takip/data/datasources/prayer_times_remote_data_source.dart';
import 'package:kaza_takip/data/models/prayer_time_model.dart';

part 'prayer_time_state.dart';

/// Aladhan tabanlı namaz vakti durum yönetimi.
///
/// Akış:
///   1. `loadForToday()` çağrıldığında önce Hive'a bakılır.
///   2. Bugünün kaydı önbellekteyse anında `Loaded` yayar.
///   3. Eksikse veya ay sonu geçtiyse uzaktan çekilir, Hive'a yazılır.
///   4. Ağ yoksa eski önbellek varsa onu kullanır; hiç yoksa `NoConnection` yayar.
class PrayerTimeCubit extends Cubit<PrayerTimeState> {
  final PrayerTimesLocalDataSource _local;
  final PrayerTimesRemoteDataSource _remote;
  final SharedPreferences _prefs;

  PrayerTimeCubit({
    required PrayerTimesLocalDataSource local,
    required PrayerTimesRemoteDataSource remote,
    required SharedPreferences prefs,
  })  : _local = local,
        _remote = remote,
        _prefs = prefs,
        super(const PrayerTimeInitial());

  String get currentCity =>
      _prefs.getString(AppConstants.prefSelectedCity) ?? AppConstants.defaultCity;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Bugünkü vakti yükler — önce önbellek, sonra ağ.
  Future<void> loadForToday() async {
    final city = currentCity;
    final now = DateTime.now();
    final cached = _local.getMonth(city: city, year: now.year, month: now.month);

    final cachedToday = _findDay(cached, now);
    final cachedNext = cached == null
        ? null
        : _findOrFetchNext(cached, city, now);

    if (cached != null && cachedToday != null && cachedNext != null) {
      emit(PrayerTimeLoaded(
        city: city,
        month: cached,
        today: cachedToday,
        nextDay: cachedNext,
      ));
      // Süresi geçmediği için arka plan tazelemesine gerek yok.
      return;
    }

    // Önbellek eksik → uzaktan çek.
    emit(PrayerTimeLoading(city));
    try {
      final fresh = await _remote.fetchMonth(
        city: city,
        year: now.year,
        month: now.month,
      );
      await _local.putMonth(
        city: city,
        year: now.year,
        month: now.month,
        data: fresh,
      );
      final today = _findDay(fresh, now);
      final next = await _resolveNextDay(fresh, city, now);
      if (today == null || next == null) {
        emit(PrayerTimeNoConnection(
          city: city,
          message: 'Vakit verisi eksik döndü, lütfen tekrar deneyin.',
        ));
        return;
      }
      emit(PrayerTimeLoaded(
        city: city,
        month: fresh,
        today: today,
        nextDay: next,
      ));
    } on PrayerTimesNetworkException catch (e) {
      // Ağ yoksa eski önbellekle devam et — yine de today bulunamadıysa hata.
      if (cached != null && cachedToday != null && cachedNext != null) {
        emit(PrayerTimeLoaded(
          city: city,
          month: cached,
          today: cachedToday,
          nextDay: cachedNext,
        ));
      } else {
        emit(PrayerTimeNoConnection(city: city, message: e.message));
      }
    }
  }

  /// Şehri değiştirir, eski önbelleği temizler ve yeniden yükler.
  Future<void> changeCity(String newCity) async {
    final trimmed = newCity.trim();
    if (trimmed.isEmpty) return;
    final oldCity = currentCity;
    await _prefs.setString(AppConstants.prefSelectedCity, trimmed);
    await _local.clearCity(oldCity);
    await loadForToday();
  }

  /// Bağlantı sonrası kullanıcıdan tekrar deneme.
  Future<void> retry() => loadForToday();

  // ── İç yardımcılar ─────────────────────────────────────────────────────────

  PrayerTimeModel? _findDay(List<PrayerTimeModel>? list, DateTime day) {
    if (list == null) return null;
    for (final m in list) {
      if (m.date.year == day.year &&
          m.date.month == day.month &&
          m.date.day == day.day) {
        return m;
      }
    }
    return null;
  }

  /// Aynı ay içindeyse yarını listede bul; ay sonundaysa sonraki ayı önbellekten dene.
  PrayerTimeModel? _findOrFetchNext(
    List<PrayerTimeModel> currentMonth,
    String city,
    DateTime today,
  ) {
    final tomorrow = today.add(const Duration(days: 1));
    final inSame = _findDay(currentMonth, tomorrow);
    if (inSame != null) return inSame;
    // Yarın yeni ay — bir sonraki ayın önbelleğine bak.
    final nextMonth = _local.getMonth(
      city: city,
      year: tomorrow.year,
      month: tomorrow.month,
    );
    return _findDay(nextMonth, tomorrow);
  }

  /// Uzaktan çekim yapıldığında yarının da garantili olmasını sağlar.
  Future<PrayerTimeModel?> _resolveNextDay(
    List<PrayerTimeModel> currentMonth,
    String city,
    DateTime today,
  ) async {
    final tomorrow = today.add(const Duration(days: 1));
    final inSame = _findDay(currentMonth, tomorrow);
    if (inSame != null) return inSame;

    // Yarın yeni ayda → sonraki ayı çek (henüz yoksa).
    var next = _local.getMonth(
      city: city,
      year: tomorrow.year,
      month: tomorrow.month,
    );
    if (next == null) {
      try {
        next = await _remote.fetchMonth(
          city: city,
          year: tomorrow.year,
          month: tomorrow.month,
        );
        await _local.putMonth(
          city: city,
          year: tomorrow.year,
          month: tomorrow.month,
          data: next,
        );
      } on PrayerTimesNetworkException {
        return null;
      }
    }
    return _findDay(next, tomorrow);
  }
}
