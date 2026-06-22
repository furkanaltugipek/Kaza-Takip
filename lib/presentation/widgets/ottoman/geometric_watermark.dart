import 'dart:math';

import 'package:flutter/material.dart';

/// Tekrar eden 8-köşeli İslami yıldız (Hatm-i Süleyman / Rub el Hizb) motifi
/// — kart arka planlarında çok düşük opaklıkta doku olarak çalışır.
class GeometricWatermarkPainter extends CustomPainter {
  /// Yıldız çizgi rengi (genelde mat altın veya emerald).
  final Color color;

  /// Çizgi opaklığı (0.03 – 0.06 önerilir).
  final double opacity;

  /// Bir hücrenin yan uzunluğu — küçük olursa daha sık desen.
  final double cellSize;

  /// Yıldız iç yarıçapı oranı (0–1).
  final double innerRatio;

  const GeometricWatermarkPainter({
    this.color = const Color(0xFFC5A059),
    this.opacity = 0.05,
    this.cellSize = 56,
    this.innerRatio = 0.42,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final rows = (size.height / cellSize).ceil() + 2;
    final cols = (size.width / cellSize).ceil() + 2;

    for (var r = -1; r < rows; r++) {
      for (var c = -1; c < cols; c++) {
        // Şaşırtmalı yerleşim — her iki satırda yarım hücre kaydır
        final offsetX = (r.isEven) ? 0.0 : cellSize / 2;
        final cx = c * cellSize + cellSize / 2 + offsetX;
        final cy = r * cellSize + cellSize / 2;
        _drawEightPointStar(canvas, paint, cx, cy, cellSize * 0.32);
      }
    }
  }

  void _drawEightPointStar(
      Canvas canvas, Paint paint, double cx, double cy, double outerR) {
    final innerR = outerR * innerRatio;
    final path = Path();
    const points = 16; // 8 dış uç + 8 iç bağlantı
    for (var i = 0; i < points; i++) {
      final angle = i * pi / 8 - pi / 2;
      final radius = i.isEven ? outerR : innerR;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant GeometricWatermarkPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.cellSize != cellSize ||
      old.innerRatio != innerRatio;
}

/// Hazır kullanım: bir Container'ın arkasına gömülecek watermark katmanı.
/// Pointer event'lerini geçirir.
class GeometricWatermark extends StatelessWidget {
  final Color color;
  final double opacity;
  final double cellSize;

  const GeometricWatermark({
    super.key,
    this.color = const Color(0xFFC5A059),
    this.opacity = 0.05,
    this.cellSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: GeometricWatermarkPainter(
          color: color,
          opacity: opacity,
          cellSize: cellSize,
        ),
        size: Size.infinite,
      ),
    );
  }
}
