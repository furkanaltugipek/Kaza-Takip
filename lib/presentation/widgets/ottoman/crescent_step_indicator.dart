import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kaza_takip/core/theme/app_colors.dart';

/// Sihirbaz/onboarding ilerlemesi için ince altın çizgi + üzerinde hareket
/// eden hilal-yıldız işaretçisi. Dolu yıldız = tamamlanmış, içi boş halka =
/// bekleyen adımlar.
class CrescentStepIndicator extends StatelessWidget {
  /// Mevcut adım (0-bazlı).
  final int currentStep;

  /// Toplam adım sayısı.
  final int totalSteps;

  /// Hilal hareketi animasyon süresi.
  final Duration duration;

  /// Çizgi rengi (pasif).
  final Color trackColor;

  /// Tamamlanmış çizgi rengi.
  final Color completedColor;

  /// İşaretçi (hilal) rengi.
  final Color markerColor;

  const CrescentStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.duration = const Duration(milliseconds: 480),
    this.trackColor = const Color(0x33C5A059),
    this.completedColor = AppColors.matteGold,
    this.markerColor = AppColors.matteGold,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final width = c.maxWidth;
        final ratio = totalSteps <= 1
            ? 0.0
            : currentStep.clamp(0, totalSteps - 1) / (totalSteps - 1);
        return SizedBox(
          height: 36,
          width: width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pasif çizgi
              Positioned(
                left: 10,
                right: 10,
                top: 17,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Tamamlanmış çizgi (animasyonlu)
              AnimatedAlign(
                alignment: Alignment.centerLeft,
                duration: duration,
                curve: Curves.easeInOutCubic,
                child: AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeInOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 2,
                  width: max(0.0, (width - 20) * ratio),
                  decoration: BoxDecoration(
                    color: completedColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Adım noktaları
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(totalSteps, (i) {
                    final done = i < currentStep;
                    final active = i == currentStep;
                    return _StepDot(
                      done: done,
                      active: active,
                      color: markerColor,
                    );
                  }),
                ),
              ),
              // Hareketli hilal işaretçisi
              AnimatedPositioned(
                duration: duration,
                curve: Curves.easeInOutCubic,
                left: 10 + (width - 20) * ratio - 11,
                top: 7,
                child: CustomPaint(
                  size: const Size(22, 22),
                  painter: _CrescentStarPainter(color: markerColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool done;
  final bool active;
  final Color color;
  const _StepDot({
    required this.done,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = active ? 14.0 : 10.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: done ? color : AppColors.paper,
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: active ? 1.6 : 1.2,
        ),
      ),
    );
  }
}

class _CrescentStarPainter extends CustomPainter {
  final Color color;
  const _CrescentStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Dış daire
    canvas.drawCircle(c, r, fill);

    // İçinden ay-kesim — hilali oluşturmak için arka plan rengiyle kesim
    final cut = Paint()
      ..color = AppColors.paper
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(
      Offset(c.dx + r * 0.4, c.dy - r * 0.05),
      r * 0.85,
      cut,
    );

    // Küçük yıldız — hilalin sağ yan boşluğuna nokta
    canvas.drawCircle(
      Offset(c.dx + r * 0.85, c.dy + r * 0.1),
      1.2,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _CrescentStarPainter old) =>
      old.color != color;
}
