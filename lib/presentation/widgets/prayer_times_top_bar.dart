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

/// Dashboard üst bandı:
/// • Gregoryen + Hicri tarih + şehir
/// • "Vaktin Çıkmasına Kalan Süre" canlı geri sayımı (HH:MM:SS)
/// • 6 vakit kartı (İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı)
/// • Dini gün/gece varsa alt alarm kartı.
///
/// Verisi [PrayerTimeCubit]'ten gelir — önce Hive önbelleği, sonra Aladhan API.
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

// ── Ortak gradient kabuk ─────────────────────────────────────────────────────

class _Shell extends StatelessWidget {
  final String? city;
  final Widget child;
  const _Shell({required this.city, required this.child});

  @override
  Widget build(BuildContext context) {
    final hijri = HijriDate.fromGregorian(DateTime.now());
    final event = IslamicEvents.eventFor(hijri);

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
          _DateHeader(hijri: hijri, city: city),
          const SizedBox(height: 16),
          child,
          if (event != null) ...[
            const SizedBox(height: 16),
            _EventAlert(eventName: event),
          ],
        ],
      ),
    );
  }
}

// ── Tarih başlığı ────────────────────────────────────────────────────────────

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
        if (city != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  city!,
                  style: AppTextStyles.bodySmall.copyWith(
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

// ── Yükleniyor: shimmer kartlar ──────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBox(
          height: 56,
          borderRadius: 16,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Vakit bilgileri yükleniyor...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
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
                  child: const _ShimmerBox(height: 64, borderRadius: 14),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double height;
  final double borderRadius;
  final Widget? child;
  const _ShimmerBox({
    required this.height,
    required this.borderRadius,
    this.child,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
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
      builder: (_, child) {
        final t = _ctrl.value;
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child == null
          ? null
          : Align(alignment: Alignment.centerLeft, child: widget.child),
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
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İlk açılışta vakitleri indirmek için bağlantı gerekli',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
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

// ── Yüklü görünüm: geri sayım + 6 kart ───────────────────────────────────────

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
    _times = widget.state.today.toDailyPrayerTimes(nextDay: widget.state.nextDay);
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
    // Gece yarısı geçtiyse bugünün kaydı geçersiz; cubit'ten yeniden iste.
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
        _Countdown(remaining: _remaining, vakitKey: _currentVakitKey),
        const SizedBox(height: 18),
        _PrayerGrid(
          today: widget.state.today,
          currentVakitKey: _currentVakitKey,
          completedToday: widget.completedToday,
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
      _VakitItem('İmsak', today.imsak,
          vakitKey: 'fajr', icon: Icons.nights_stay_outlined),
      _VakitItem('Güneş', today.gunes,
          vakitKey: null, icon: Icons.wb_twilight),
      _VakitItem('Öğle', today.dhuhr,
          vakitKey: 'dhuhr', icon: Icons.wb_sunny_outlined),
      _VakitItem('İkindi', today.asr,
          vakitKey: 'asr', icon: Icons.wb_cloudy_outlined),
      _VakitItem('Akşam', today.maghrib,
          vakitKey: 'maghrib', icon: Icons.brightness_4_outlined),
      _VakitItem('Yatsı', today.isha,
          vakitKey: 'isha', icon: Icons.bedtime_outlined),
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
  final String time; // HH:mm
  final String? vakitKey;
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
            item.time,
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
