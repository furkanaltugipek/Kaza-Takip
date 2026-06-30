import 'package:flutter/material.dart';

/// Bir alanın dört köşesine zarif tezhip-tarzı altın süslemeler çizer.
/// Geri sayım metni gibi öne çıkarılacak içeriklerin etrafını çerçeveler.
class TezhipCornersPainter extends CustomPainter {
  /// Altın rengi.
  final Color color;

  /// Köşe motifinin yan uzunluğu (px).
  final double cornerSize;

  /// Çizgi kalınlığı.
  final double strokeWidth;

  /// İçe-dışa marj — köşelerden ne kadar uzakta çizilsin.
  final double inset;

  const TezhipCornersPainter({
    this.color = const Color(0xFFC5A059),
    this.cornerSize = 16,
    this.strokeWidth = 1.2,
    this.inset = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;
    final s = cornerSize;
    final i = inset;

    // Sol-üst
    _drawCorner(canvas, paint, fillPaint, Offset(i, i), s, 0);
    // Sağ-üst
    _drawCorner(canvas, paint, fillPaint, Offset(w - i, i), s, 1);
    // Sağ-alt
    _drawCorner(canvas, paint, fillPaint, Offset(w - i, h - i), s, 2);
    // Sol-alt
    _drawCorner(canvas, paint, fillPaint, Offset(i, h - i), s, 3);
  }

  /// `corner` 0=TL, 1=TR, 2=BR, 3=BL.
  /// Çizilen motif: küçük bir L kıvrımı + iç tarafa bakan minik altın damla.
  void _drawCorner(
    Canvas canvas,
    Paint stroke,
    Paint fill,
    Offset o,
    double s,
    int corner,
  ) {
    // Birim yön vektörleri (içeri doğru): TL = (+1,+1), TR = (-1,+1) vb.
    final dx = (corner == 0 || corner == 3) ? 1.0 : -1.0;
    final dy = (corner == 0 || corner == 1) ? 1.0 : -1.0;

    final path = Path();
    // Yatay kol — köşeden içeri
    path.moveTo(o.dx + dx * s, o.dy);
    path.lineTo(o.dx + dx * (s * 0.35), o.dy);
    // Yumuşak iç kavis köşeye doğru
    path.quadraticBezierTo(
      o.dx, o.dy,
      o.dx, o.dy + dy * (s * 0.35),
    );
    // Dikey kol — köşeden içeri
    path.lineTo(o.dx, o.dy + dy * s);
    canvas.drawPath(path, stroke);

    // Köşe kavisinin iç tarafına minik altın noktası — Tezhip damlası
    canvas.drawCircle(
      Offset(o.dx + dx * (s * 0.62), o.dy + dy * (s * 0.62)),
      1.6,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant TezhipCornersPainter old) =>
      old.color != color ||
      old.cornerSize != cornerSize ||
      old.strokeWidth != strokeWidth ||
      old.inset != inset;
}

/// Child'ın dört köşesine tezhip motifleri ekleyen sarmalayıcı.
class TezhipFrame extends StatelessWidget {
  final Widget child;
  final Color color;
  final double cornerSize;
  final EdgeInsets padding;

  const TezhipFrame({
    super.key,
    required this.child,
    this.color = const Color(0xFFC5A059),
    this.cornerSize = 16,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.all(6), child: child),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: TezhipCornersPainter(
                  color: color,
                  cornerSize: cornerSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
