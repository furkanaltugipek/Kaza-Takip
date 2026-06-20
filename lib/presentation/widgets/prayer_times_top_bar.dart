import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/hijri_converter.dart';
import 'package:kaza_takip/core/utils/islamic_events.dart';
import 'package:kaza_takip/core/utils/prayer_times_helper.dart';

/// Dashboard üst bandı:
/// • Gregoryen + Hicri tarih
/// • "Vaktin Çıkmasına Kalan Süre" canlı geri sayımı (HH:MM:SS)
/// • 6 vakit kartı (İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı)
/// • Dini gün/gece varsa alt alarm kartı.
class PrayerTimesTopBar extends StatefulWidget {
  /// Her vakit anahtarı (fajr/dhuhr/asr/maghrib/isha) için bugün
  /// tamamlanmış kaza sayısı — kart tik simgesini tetikler.
  final Map<String, int> completedToday;

  const PrayerTimesTopBar({
    super.key,
    required this.completedToday,
  });

  @override
  State<PrayerTimesTopBar> createState() => _PrayerTimesTopBarState();
}

class _PrayerTimesTopBarState extends State<PrayerTimesTopBar> {
  late DailyPrayerTimes _times;
  late HijriDate _hijri;
  String? _todayEvent;
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  String _currentVakitKey = 'fajr';

  @override
  void initState() {
    super.initState();
    _times = PrayerTimesHelper.today();
    _hijri = HijriDate.fromGregorian(DateTime.now());
    _todayEvent = IslamicEvents.eventFor(_hijri);
    _recompute();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _recompute());
  }

  void _recompute() {
    final now = DateTime.now();
    final end = _times.currentVakitEnd(now);
    final diff = end.difference(now);

    // Vakit geçtiyse yeni vakte sıçra — gece yarısı geçişlerinde
    // tablo güncellenecek.
    if (diff.isNegative) {
      _times = PrayerTimesHelper.today();
      _hijri = HijriDate.fromGregorian(now);
      _todayEvent = IslamicEvents.eventFor(_hijri);
    }

    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
      _currentVakitKey = _times.currentVakitKey(now);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DateHeader(hijri: _hijri),
          const SizedBox(height: 16),
          _Countdown(remaining: _remaining, vakitKey: _currentVakitKey),
          const SizedBox(height: 18),
          _PrayerGrid(
            times: _times,
            currentVakitKey: _currentVakitKey,
            completedToday: widget.completedToday,
          ),
          if (_todayEvent != null) ...[
            const SizedBox(height: 16),
            _EventAlert(eventName: _todayEvent!),
          ],
        ],
      ),
    );
  }
}

// ── Tarih başlığı ────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final HijriDate hijri;
  const _DateHeader({required this.hijri});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', 'tr_TR').format(now);
    final gregorian = DateFormat('d MMMM y', 'tr_TR').format(now);

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.brightness_2_outlined,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white70,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$gregorian / ${hijri.formatTr()}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Geri sayım ───────────────────────────────────────────────────────────────

class _Countdown extends StatelessWidget {
  final Duration remaining;
  final String vakitKey;
  const _Countdown({required this.remaining, required this.vakitKey});

  static const Map<String, String> _vakitLabels = {
    'fajr': 'Sabah',
    'dhuhr': 'Öğle',
    'asr': 'İkindi',
    'maghrib': 'Akşam',
    'isha': 'Yatsı',
  };

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final label = _vakitLabels[vakitKey] ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vaktin Çıkmasına Kalan Süre',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$label vakti',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.secondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _fmt(remaining),
            style: AppTextStyles.displayMedium.copyWith(
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
              fontSize: 28,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vakit kartları (3x2) ─────────────────────────────────────────────────────

class _PrayerGrid extends StatelessWidget {
  final DailyPrayerTimes times;
  final String currentVakitKey;
  final Map<String, int> completedToday;

  const _PrayerGrid({
    required this.times,
    required this.currentVakitKey,
    required this.completedToday,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_VakitItem>[
      _VakitItem('İmsak', times.imsak, vakitKey: 'fajr', icon: Icons.nights_stay_outlined),
      _VakitItem('Güneş', times.gunes, vakitKey: null, icon: Icons.wb_twilight),
      _VakitItem('Öğle', times.dhuhr, vakitKey: 'dhuhr', icon: Icons.wb_sunny_outlined),
      _VakitItem('İkindi', times.asr, vakitKey: 'asr', icon: Icons.wb_cloudy_outlined),
      _VakitItem('Akşam', times.maghrib, vakitKey: 'maghrib', icon: Icons.brightness_4_outlined),
      _VakitItem('Yatsı', times.isha, vakitKey: 'isha', icon: Icons.bedtime_outlined),
    ];

    return LayoutBuilder(
      builder: (ctx, c) {
        final w = (c.maxWidth - 16) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((it) {
            final isActive = it.vakitKey != null &&
                it.vakitKey == currentVakitKey;
            final isCompleted = it.vakitKey != null &&
                (completedToday[it.vakitKey] ?? 0) > 0;
            return SizedBox(
              width: w,
              child: _PrayerCard(
                item: it,
                isActive: isActive,
                isCompleted: isCompleted,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _VakitItem {
  final String label;
  final DateTime time;
  final String? vakitKey; // null → Güneş (kaza yok)
  final IconData icon;
  const _VakitItem(
    this.label,
    this.time, {
    required this.vakitKey,
    required this.icon,
  });
}

class _PrayerCard extends StatelessWidget {
  final _VakitItem item;
  final bool isActive;
  final bool isCompleted;

  const _PrayerCard({
    required this.item,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isActive ? AppColors.secondary : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withOpacity(0.20)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? AppColors.secondary
              : (isActive
                  ? AppColors.secondaryLight
                  : Colors.white.withOpacity(0.18)),
          width: isCompleted || isActive ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 14, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle,
                    size: 14, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('HH:mm').format(item.time),
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dini gün/gece uyarısı ────────────────────────────────────────────────────

class _EventAlert extends StatelessWidget {
  final String eventName;
  const _EventAlert({required this.eventName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withOpacity(0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star_rounded,
              color: AppColors.secondaryLight, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bugün $eventName. Kaza borçlarınızı eritmek ve nafile '
              'ibadetlerinizi artırmak için çok bereketli bir gün!',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
