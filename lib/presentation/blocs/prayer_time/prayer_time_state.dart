part of 'prayer_time_cubit.dart';

sealed class PrayerTimeState extends Equatable {
  const PrayerTimeState();
  @override
  List<Object?> get props => [];
}

class PrayerTimeInitial extends PrayerTimeState {
  const PrayerTimeInitial();
}

/// Önbellek boş ve ağdan çekiliyor.
class PrayerTimeLoading extends PrayerTimeState {
  final String city;
  const PrayerTimeLoading(this.city);
  @override
  List<Object?> get props => [city];
}

/// Hem önbellek hem ağ verisi mevcut; UI normal çalışır.
class PrayerTimeLoaded extends PrayerTimeState {
  final String city;
  final List<PrayerTimeModel> month;
  final PrayerTimeModel today;
  final PrayerTimeModel nextDay;

  /// Arka planda taze veri çekiliyor (önbellek gösteriliyor).
  final bool refreshing;

  const PrayerTimeLoaded({
    required this.city,
    required this.month,
    required this.today,
    required this.nextDay,
    this.refreshing = false,
  });

  PrayerTimeLoaded copyWith({bool? refreshing}) => PrayerTimeLoaded(
        city: city,
        month: month,
        today: today,
        nextDay: nextDay,
        refreshing: refreshing ?? this.refreshing,
      );

  @override
  List<Object?> get props => [city, month, today, nextDay, refreshing];
}

/// Hiç önbellek yok ve ağ başarısız — kullanıcıdan bağlantı istenir.
class PrayerTimeNoConnection extends PrayerTimeState {
  final String city;
  final String message;
  const PrayerTimeNoConnection({required this.city, required this.message});
  @override
  List<Object?> get props => [city, message];
}
