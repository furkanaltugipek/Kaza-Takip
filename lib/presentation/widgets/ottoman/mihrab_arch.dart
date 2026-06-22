import 'package:flutter/material.dart';

/// Üst kenarında yumuşak bir Mihrab kemeri / kubbe ucu bulunan kart şekli.
///
/// Klasik dik dikdörtgen yerine bu şekil — alt köşeleri yuvarlatılmış,
/// üst kenarı merkeze doğru hafifçe sivrilen — kart konteynerlerinin
/// üst kısmına ince bir Osmanlı sezgisi katar.
class MihrabArchClipper extends CustomClipper<Path> {
  /// Üst merkezdeki kubbe yüksekliği (px) — küçük tutulur, ince bir vurgu.
  final double archHeight;

  /// Alt köşelerin yarıçapı.
  final double bottomRadius;

  const MihrabArchClipper({
    this.archHeight = 14,
    this.bottomRadius = 18,
  });

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = bottomRadius;

    final path = Path();
    // Sol omuz hizasından başla (kemerin alt seviyesi)
    path.moveTo(0, archHeight);
    // Sol yarım kemer — cubic ile yumuşak yükseliş ve sivrilme
    path.cubicTo(
      w * 0.12, archHeight * 0.15,
      w * 0.38, 0,
      w / 2, 0,
    );
    // Sağ yarım kemer
    path.cubicTo(
      w * 0.62, 0,
      w * 0.88, archHeight * 0.15,
      w, archHeight,
    );
    // Sağ kenar aşağı
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);
    // Alt kenar
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);
    // Sol kenar yukarı (kapanış)
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is! MihrabArchClipper ||
        oldClipper.archHeight != archHeight ||
        oldClipper.bottomRadius != bottomRadius;
  }
}

/// Mihrab kemerli yolun aynısını çizgi olarak çizen border painter.
/// Container'ın `foregroundDecoration` veya CustomPaint ile birlikte
/// kullanılır.
class MihrabBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double archHeight;
  final double bottomRadius;

  const MihrabBorderPainter({
    required this.color,
    this.strokeWidth = 1.2,
    this.archHeight = 14,
    this.bottomRadius = 18,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final clipper = MihrabArchClipper(
      archHeight: archHeight,
      bottomRadius: bottomRadius,
    );
    final path = clipper.getClip(size);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MihrabBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.archHeight != archHeight ||
      old.bottomRadius != bottomRadius;
}

/// Mihrab şekilli kart konteyneri — child + opsiyonel altın kenarlık.
/// `prayer_times_top_bar` gibi öne çıkarılacak elemanlarda kullanılır.
class MihrabCard extends StatelessWidget {
  final Widget child;
  final Color background;
  final Color? borderColor;
  final double borderWidth;
  final double archHeight;
  final double bottomRadius;
  final EdgeInsets padding;
  final List<BoxShadow> shadows;

  const MihrabCard({
    super.key,
    required this.child,
    this.background = const Color(0xFFFFFFFF),
    this.borderColor,
    this.borderWidth = 1.2,
    this.archHeight = 14,
    this.bottomRadius = 18,
    this.padding = const EdgeInsets.all(20),
    this.shadows = const [],
  });

  @override
  Widget build(BuildContext context) {
    final clipper = MihrabArchClipper(
      archHeight: archHeight,
      bottomRadius: bottomRadius,
    );

    Widget core = ClipPath(
      clipper: clipper,
      child: Container(
        color: background,
        padding: padding.copyWith(top: padding.top + archHeight),
        child: child,
      ),
    );

    if (borderColor != null) {
      core = Stack(
        children: [
          core,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: MihrabBorderPainter(
                  color: borderColor!,
                  strokeWidth: borderWidth,
                  archHeight: archHeight,
                  bottomRadius: bottomRadius,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (shadows.isNotEmpty) {
      core = DecoratedBox(
        decoration: BoxDecoration(boxShadow: shadows),
        child: core,
      );
    }

    return core;
  }
}
