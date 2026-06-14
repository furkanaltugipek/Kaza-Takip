import 'dart:math' as math;

/// Kâbe'nin coğrafi koordinatları.
const double kKaabaLatitude = 21.4225;
const double kKaabaLongitude = 39.8262;

/// Büyük daire (great-circle) formülüyle kullanıcının bulunduğu noktadan
/// Kâbe'ye olan **gerçek (true north)** yön açısını derece cinsinden döner.
/// 0° = Kuzey, 90° = Doğu, 180° = Güney, 270° = Batı.
double computeQiblaBearing({
  required double latitude,
  required double longitude,
}) {
  final phi1 = _deg2rad(latitude);
  final phi2 = _deg2rad(kKaabaLatitude);
  final deltaLambda = _deg2rad(kKaabaLongitude - longitude);

  final y = math.sin(deltaLambda) * math.cos(phi2);
  final x = math.cos(phi1) * math.sin(phi2) -
      math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

  final bearingRad = math.atan2(y, x);
  final bearingDeg = _rad2deg(bearingRad);
  return (bearingDeg + 360) % 360;
}

double _deg2rad(double d) => d * math.pi / 180.0;
double _rad2deg(double r) => r * 180.0 / math.pi;
