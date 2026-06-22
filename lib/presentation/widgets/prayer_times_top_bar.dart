import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/hijri_converter.dart';
import 'package:kaza_takip/core/utils/islamic_events.dart';
import 'package:kaza_takip/core/utils/prayer_times_helper.dart';
import 'package:kaza_takip/data/models/prayer_time_model.dart';
import 'package:kaza_takip/presentation/blocs/prayer_time/prayer_time_cubit.dart';
import 'package:kaza_takip/presentation/widgets/ottoman/geometric_watermark.dart';
import 'package:kaza_takip/presentation/widgets/ottoman/mihrab_arch.dart';
import 'package:kaza_takip/presentation/widgets/ottoman/tezhip_corners.dart';

/// Neo-Ottoman dashboard üst bandı.
///
/// • Krem zemin + ince geometrik filigran
/// • Mihrab kemerli, mat-altın kenarlı geri sayım kartı (tezhip köşeleri ile)
/// • Iznik karo ilhamlı 6 vakit kartı — tamamlananlarda emerald + altın tik
class PrayerTimesTopBar extends StatelessWidget {
  /// Her vakit anahtarı (fajr/dhuhr/asr/maghrib/isha) için bugün
  /// tamamlanmış kaza sayısı — kart tik simgesini tetikler.
  final Map<String, int> completedToday;

  const PrayerTimesTopBar({super.key, required this.completedToday});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
      builder: (ctx, state) {
        return _Shell(
          city: switch (state) {
            PrayerTimeLoading(:final city) => city,
            PrayerTimeLoaded(:final city) => city,
            PrayerTimeNoConnection(:final city) => city,
            _ => null,
          },
          child: switch (state) {
            PrayerTimeLoaded() => _LoadedView(
                state: state,
                completedToday: completedToday,
              ),
            PrayerTimeNoConnection() => _OfflinePrompt(state: state),
            _ => const _LoadingView(),
          },
        );
      },
    );
  }
}

// ── Dış kabuk — Mihrab kart + filigran + tarih başlığı + dini gün uyarısı ────

class _Shell extends StatelessWidget {
  final String? city;
  final Widget child;
  const _Shell({required this.city, required this.child});

  @override
  Widget build(BuildContext context) {
    final hijri = HijriDate.fromGregorian(DateTime.now());
    final event = IslamicEvents.eventFor(hijri);

    return MihrabCard(
      background: AppColors.paper,
      borderColor: AppColors.matteGold,
      borderWidth: 1.2,
      archHeight: 18,
      bottomRadius: 22,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      shadows: const [
        BoxShadow(
          color: Color(0x14C5A059),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
      child: Stack(
        children: [
          // Arka plan filigranı — subtle Islamic geometric pattern
          Positioned.fill(
            child: ClipRect(
              child: GeometricWatermark(
                color: AppColors.matteGold,
                opacity: 0.045,
                cellSize: 58,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateHeader(hijri: hijri, city: city),
              const SizedBox(height: 18),
              child,
              if (event != null) ...[
                const SizedBox(height: 16),
                _EventAlert(eventName: event),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tarih başlığı (Gregoryen + Hicri + Şehir) ────────────────────────────────

class _DateHeader extends StatelessWidget {
  final HijriDate hijri;
  final String? city;
  const _DateHeader({required this.hijri, required this.city});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', 'tr_TR').format(now);
    final gregorian = DateFormat('d MMMM y', 'tr_TR').format(now);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayName.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.matteGoldDark,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                gregorian,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 2),
              Text(
                hijri.formatTr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.matteGoldDark,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        if (city != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.matteGold, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: AppColors.imperial),
                const SizedBox(width: 4),
                Text(
                  city!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.imperial,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Yükleniyor: shimmer kartlar ──────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.matteGold, width: 0.8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.matteGold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Vakit bilgileri yükleniyor…',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.imperial),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (ctx, c) {
            final w = (c.maxWidth - 16) / 3;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                6,
                (_) => SizedBox(
                  width: w,
                  child: const _ShimmerTile(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ShimmerTile extends StatefulWidget {
  const _ShimmerTile();

  @override
  State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Container(
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.8),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: const [
                AppColors.cream,
                Color(0xFFFAF5E5),
                AppColors.cream,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Çevrimdışı uyarısı ───────────────────────────────────────────────────────

class _OfflinePrompt extends StatelessWidget {
  final PrayerTimeNoConnection state;
  const _OfflinePrompt({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.matteGold, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.matteGoldDark, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İlk açılışta vakitleri indirmek için bağlantı gerekli',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.imperial),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Tekrar Dene'),
                  onPressed: () => context.read<PrayerTimeCubit>().retry(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Yüklü: geri sayım + 6 vakit Iznik kartı ──────────────────────────────────

class _LoadedView extends StatefulWidget {
  final PrayerTimeLoaded state;
  final Map<String, int> completedToday;
  const _LoadedView({required this.state, required this.completedToday});

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  late DailyPrayerTimes _times;
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  String _currentVakitKey = 'fajr';

  @override
  void initState() {
    super.initState();
    _rebuildTimes();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _recompute());
    _recompute();
  }

  @override
  void didUpdateWidget(covariant _LoadedView old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      _rebuildTimes();
      _recompute();
    }
  }

  void _rebuildTimes() {
    _times = widget.state.today
        .toDailyPrayerTimes(nextDay: widget.state.nextDay);
  }

  void _recompute() {
    final now = DateTime.now();
    final end = _times.currentVakitEnd(now);
    final diff = end.difference(now);
    if (!mounted) return;
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
      _currentVakitKey = _times.currentVakitKey(now);
    });
    final today = widget.state.today.date;
    if (now.year != today.year ||
        now.month != today.month ||
        now.day != today.day) {
      context.read<PrayerTimeCubit>().loadForToday();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CountdownCard(
          remaining: _remaining,
          vakitKey: _currentVakitKey,
        ),
        const SizedBox(height: 14),
        _PrayerGrid(
          today: widget.state.today,
          currentVakitKey: _currentVakitKey,
          completedToday: widget.completedToday,
        ),
      ],
    );
  }
}

// ── Geri sayım — flagship kart (altın kenar + watermark + tezhip köşeler) ────

class _CountdownCard extends StatelessWidget {
  final Duration remaining;
  final String vakitKey;
  const _CountdownCard({required this.remaining, required this.vakitKey});

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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.matteGold, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10C5A059),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // İnce filigran arka plan
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GeometricWatermark(
                color: AppColors.imperial,
                opacity: 0.035,
                cellSize: 44,
              ),
            ),
          ),
          // Tezhip köşeler
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: TezhipCornersPainter(
                  color: AppColors.matteGold,
                  cornerSize: 14,
                  strokeWidth: 1.1,
                  inset: 6,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'VAKTİN ÇIKMASINA KALAN SÜRE',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.matteGoldDark,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _fmt(remaining),
                  style: AppTextStyles.countdown,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 18,
                      height: 1,
                      color: AppColors.matteGold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$label Vakti',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.imperial,
                        letterSpacing: 1.2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 18,
                      height: 1,
                      color: AppColors.matteGold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 6 vakit Iznik-tarzı kart grid ────────────────────────────────────────────

class _PrayerGrid extends StatelessWidget {
  final PrayerTimeModel today;
  final String currentVakitKey;
  final Map<String, int> completedToday;

  const _PrayerGrid({
    required this.today,
    required this.currentVakitKey,
    required this.completedToday,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_VakitItem>[
      _VakitItem('İmsak', today.imsak, vakitKey: 'fajr'),
      _VakitItem('Güneş', today.gunes, vakitKey: null),
      _VakitItem('Öğle', today.dhuhr, vakitKey: 'dhuhr'),
      _VakitItem('İkindi', today.asr, vakitKey: 'asr'),
      _VakitItem('Akşam', today.maghrib, vakitKey: 'maghrib'),
      _VakitItem('Yatsı', today.isha, vakitKey: 'isha'),
    ];

    return LayoutBuilder(
      builder: (ctx, c) {
        final w = (c.maxWidth - 16) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((it) {
            final isActive =
                it.vakitKey != null && it.vakitKey == currentVakitKey;
            final isCompleted = it.vakitKey != null &&
                (completedToday[it.vakitKey] ?? 0) > 0;
            return SizedBox(
              width: w,
              child: _IznikTile(
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
  final String time; // HH:mm
  final String? vakitKey;
  const _VakitItem(this.label, this.time, {required this.vakitKey});
}

class _IznikTile extends StatelessWidget {
  final _VakitItem item;
  final bool isActive;
  final bool isCompleted;

  const _IznikTile({
    required this.item,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Tamamlanmış → emerald zemin + krem yazı + altın tik
    // Aktif → krem zemin + altın kenarlık (çift kontur hissi)
    // Pasif → krem zemin + ince divider kenarlık
    final Color bg;
    final Color textColor;
    final Color borderColor;
    final double borderWidth;

    if (isCompleted) {
      bg = AppColors.imperial;
      textColor = AppColors.paper;
      borderColor = AppColors.matteGold;
      borderWidth = 1.2;
    } else if (isActive) {
      bg = AppColors.cream;
      textColor = AppColors.imperial;
      borderColor = AppColors.matteGold;
      borderWidth = 1.4;
    } else {
      bg = AppColors.paper;
      textColor = AppColors.imperial;
      borderColor = AppColors.divider;
      borderWidth = 0.9;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label.toUpperCase(),
                style: AppTextStyles.prayerLabel.copyWith(
                  color: isCompleted
                      ? AppColors.matteGoldLight
                      : AppColors.matteGoldDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                item.time,
                style: AppTextStyles.timeNumeric.copyWith(
                  color: textColor,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          if (isCompleted)
            const Positioned(
              top: -2,
              right: -2,
              child: Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.matteGold,
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
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.matteGold, width: 0.9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome,
              color: AppColors.matteGoldDark, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.imperialDark,
                  height: 1.45,
                ),
                children: [
                  TextSpan(
                    text: 'Bugün $eventName. ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.imperial,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'Kaza borçlarınızı eritmek ve nafile ibadetlerinizi artırmak için çok bereketli bir gün!',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
