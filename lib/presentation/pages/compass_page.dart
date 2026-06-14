import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';
import 'package:kaza_takip/core/theme/app_text_styles.dart';
import 'package:kaza_takip/core/utils/qibla_calculator.dart';

/// Kıble Pusulası — manyetik sensör + cihaz konumu ile Kâbe'ye yön gösterir.
class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

enum _PermissionState { unknown, granted, denied, serviceDisabled, unavailable }

class _CompassPageState extends State<CompassPage> {
  _PermissionState _perm = _PermissionState.unknown;
  double? _qiblaBearing; // konum bazlı (true north → Kâbe)
  double? _heading; // cihazın baktığı yön (manyetik kuzey'e göre)
  StreamSubscription<CompassEvent>? _sub;
  bool _sensorAvailable = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final ok = await _requestLocation();
    if (!ok) return;
    _startCompass();
  }

  Future<bool> _requestLocation() async {
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        setState(() => _perm = _PermissionState.serviceDisabled);
        return false;
      }

      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.denied ||
          p == LocationPermission.deniedForever) {
        setState(() => _perm = _PermissionState.denied);
        return false;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      setState(() {
        _qiblaBearing = computeQiblaBearing(
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
        _perm = _PermissionState.granted;
      });
      return true;
    } catch (_) {
      setState(() => _perm = _PermissionState.unavailable);
      return false;
    }
  }

  void _startCompass() {
    final stream = FlutterCompass.events;
    if (stream == null) {
      setState(() => _sensorAvailable = false);
      return;
    }
    _sub = stream.listen((e) {
      if (!mounted) return;
      final h = e.heading;
      if (h == null) {
        setState(() => _sensorAvailable = false);
        return;
      }
      setState(() => _heading = h < 0 ? h + 360 : h);
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_perm) {
      _PermissionState.granted => _buildCompass(),
      _PermissionState.serviceDisabled => _OnboardingOverlay(
          icon: Icons.location_off_outlined,
          title: 'Konum Servisi Kapalı',
          message:
              'Kıble yönünü hesaplayabilmem için cihazınızın konum servisini açmanız gerekiyor.',
          actionLabel: 'Ayarları Aç',
          onAction: Geolocator.openLocationSettings,
          onRetry: _init,
        ),
      _PermissionState.denied => _OnboardingOverlay(
          icon: Icons.lock_outline,
          title: 'Konum İzni Gerekli',
          message:
              'Bulunduğunuz konuma göre Kâbe\'nin tam yönünü göstermek için uygulamaya konum izni vermelisiniz.',
          actionLabel: 'Uygulama Ayarları',
          onAction: Geolocator.openAppSettings,
          onRetry: _init,
        ),
      _PermissionState.unavailable => _OnboardingOverlay(
          icon: Icons.error_outline,
          title: 'Konum Alınamadı',
          message:
              'Cihazınızdan konum bilgisi okunamadı. GPS sinyali ve servisler aktif olmalı.',
          actionLabel: 'Tekrar Dene',
          onAction: _init,
        ),
      _PermissionState.unknown => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
    };
  }

  Widget _buildCompass() {
    if (!_sensorAvailable) {
      return _OnboardingOverlay(
        icon: Icons.sensors_off_outlined,
        title: 'Pusula Sensörü Yok',
        message:
            'Cihazınızda manyetometre sensörü bulunamadı. Pusula bu cihazda kullanılamaz.',
        actionLabel: 'Tekrar Dene',
        onAction: _init,
      );
    }
    if (_heading == null || _qiblaBearing == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final heading = _heading!;
    final qibla = _qiblaBearing!;
    // Compass needle açısı: kuzey hep yukarıda kalmalı → -heading.
    // Kâbe ikonu Kâbe yönüne sabit → qibla - heading.
    final aligned = (((qibla - heading) % 360) + 360) % 360;
    final alignment = (aligned - 0).abs();
    final aligned360 = alignment > 180 ? 360 - alignment : alignment;
    final isAligned = aligned360 < 5;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          const SizedBox(height: 24),
          _StatBar(
            heading: heading,
            qibla: qibla,
            isAligned: isAligned,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    turns: -heading / 360,
                    child: CustomPaint(
                      painter: _CompassPainter(
                        qiblaBearing: qibla,
                        aligned: isAligned,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _Footer(isAligned: isAligned, deltaDeg: aligned360),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Üst durum çubuğu ─────────────────────────────────────────────────────────

class _StatBar extends StatelessWidget {
  final double heading;
  final double qibla;
  final bool isAligned;
  const _StatBar({
    required this.heading,
    required this.qibla,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _Chip(label: 'Cihaz', value: '${heading.toStringAsFixed(0)}°'),
          const SizedBox(width: 8),
          _Chip(label: 'Kıble', value: '${qibla.toStringAsFixed(0)}°'),
          const Spacer(),
          if (isAligned)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle,
                      size: 16, color: AppColors.success),
                  SizedBox(width: 4),
                  Text(
                    'Hizalandı',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  const _Chip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF666666)),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Alt metin ────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final bool isAligned;
  final double deltaDeg;
  const _Footer({required this.isAligned, required this.deltaDeg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            isAligned
                ? 'Telefonu sabit tutun — yön Kâbe\'ye çevrildi.'
                : 'Telefonu yatay tutun ve oku Kâbe ikonuna doğru çevirin.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (!isAligned) ...[
            const SizedBox(height: 6),
            Text(
              'Sapma: ${deltaDeg.toStringAsFixed(1)}°',
              style: AppTextStyles.bodySmall
                  .copyWith(color: const Color(0xFF888888)),
            ),
          ],
        ],
      ),
    );
  }
}

// ── İzin / hata kartı ────────────────────────────────────────────────────────

class _OnboardingOverlay extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback? onRetry;

  const _OnboardingOverlay({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(title, style: AppTextStyles.headlineLarge),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium
                .copyWith(color: const Color(0xFF555555), height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Pusula çizimi ────────────────────────────────────────────────────────────

class _CompassPainter extends CustomPainter {
  final double qiblaBearing;
  final bool aligned;
  _CompassPainter({required this.qiblaBearing, required this.aligned});

  static const _cardinalLabels = ['K', 'D', 'G', 'B'];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    // Dış halka
    final ringPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, ringPaint);

    final borderPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // İç gradient diski
    final innerR = radius * 0.78;
    final innerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.08),
          AppColors.surface,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: innerR));
    canvas.drawCircle(center, innerR, innerPaint);

    // Derece çizgileri (her 6°)
    final tickPaint = Paint()..strokeWidth = 1;
    for (var deg = 0; deg < 360; deg += 6) {
      final isMajor = deg % 30 == 0;
      final isCardinal = deg % 90 == 0;
      tickPaint
        ..color = isCardinal
            ? AppColors.primary
            : (isMajor
                ? const Color(0xFF666666)
                : const Color(0xFFBBBBBB))
        ..strokeWidth = isCardinal ? 2.5 : (isMajor ? 1.5 : 0.8);
      final outer = _polar(center, radius - 6, deg.toDouble());
      final inner = _polar(
        center,
        radius - (isMajor ? 18 : 10),
        deg.toDouble(),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Yön etiketleri (K D G B)
    for (var i = 0; i < 4; i++) {
      final angle = i * 90.0;
      final pos = _polar(center, radius - 36, angle);
      final tp = TextPainter(
        text: TextSpan(
          text: _cardinalLabels[i],
          style: TextStyle(
            color: i == 0 ? AppColors.error : AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    // Kıble göstergesi — Kâbe simgesi
    final kaabaPos = _polar(center, radius * 0.55, qiblaBearing);
    final kaabaRect = Rect.fromCenter(
      center: kaabaPos,
      width: 38,
      height: 38,
    );
    final kaabaBgPaint = Paint()
      ..color = aligned ? AppColors.success : AppColors.secondary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(kaabaRect, const Radius.circular(6)),
      kaabaBgPaint,
    );
    // Kâbe örtü çizgisi
    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(kaabaRect.left + 3, kaabaRect.top + 12),
      Offset(kaabaRect.right - 3, kaabaRect.top + 12),
      stripePaint,
    );

    // Kâbe yön çizgisi (merkez → Kâbe)
    final qiblaLinePaint = Paint()
      ..color = (aligned ? AppColors.success : AppColors.secondary)
          .withOpacity(0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, kaabaPos, qiblaLinePaint);

    // Ana ok (kuzeye sabit gösterir; tüm canvas zaten -heading kadar dönüyor).
    _drawNeedle(canvas, center, radius);

    // Merkez nokta
    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(center, 8, dotPaint);
    canvas.drawCircle(
      center,
      4,
      Paint()..color = Colors.white,
    );
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final length = radius * 0.62;
    // Kırmızı uç (kuzeye bakıyor — 0°)
    final north = _polar(center, length, 0);
    final south = _polar(center, length * 0.6, 180);
    final left = _polar(center, 14, 270);
    final right = _polar(center, 14, 90);

    final northPath = Path()
      ..moveTo(north.dx, north.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(
      northPath,
      Paint()..color = AppColors.error,
    );

    final southPath = Path()
      ..moveTo(south.dx, south.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(
      southPath,
      Paint()..color = const Color(0xFF333333),
    );
  }

  /// Yukarısı 0° (kuzey) olacak şekilde polar → kartezyen dönüşüm.
  Offset _polar(Offset center, double r, double deg) {
    final rad = (deg - 90) * math.pi / 180;
    return Offset(
      center.dx + r * math.cos(rad),
      center.dy + r * math.sin(rad),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) =>
      old.qiblaBearing != qiblaBearing || old.aligned != aligned;
}
