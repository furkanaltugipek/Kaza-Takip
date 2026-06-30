import 'hijri_converter.dart';

/// Önemli dini gün ve geceleri tutan basit yardımcı sınıf.
///
/// Anahtar "MM-DD" biçiminde (ay-gün), değer Türkçe etkinlik adıdır.
/// Yıla bağlı tek gün gerektiren etkinlikler için tek anahtar, çok günlü olanlar
/// için her gün ayrı anahtar tutulur.
class IslamicEvents {
  IslamicEvents._();

  /// Hicri (ay, gün) → etkinlik adı eşlemesi.
  static const Map<String, String> _events = {
    // Muharrem
    '1-1': 'Hicri Yılbaşı',
    '1-10': 'Aşure Günü',

    // Rebiülevvel
    '3-12': 'Mevlid Kandili',

    // Recep
    '7-1': 'Üç Ayların Başlangıcı',
    '7-5': 'Regaib Kandili',
    '7-27': 'Miraç Kandili',

    // Şaban
    '8-15': 'Berat Kandili',

    // Ramazan
    '9-1': 'Ramazan Ayının İlk Günü',
    '9-27': 'Kadir Gecesi',

    // Şevval
    '10-1': 'Ramazan Bayramı (1. Gün)',
    '10-2': 'Ramazan Bayramı (2. Gün)',
    '10-3': 'Ramazan Bayramı (3. Gün)',

    // Zilhicce
    '12-9': 'Arefe Günü',
    '12-10': 'Kurban Bayramı (1. Gün)',
    '12-11': 'Kurban Bayramı (2. Gün)',
    '12-12': 'Kurban Bayramı (3. Gün)',
    '12-13': 'Kurban Bayramı (4. Gün)',
  };

  /// Verilen Hicri tarih bir etkinliğe denk geliyorsa adını döndürür.
  static String? eventFor(HijriDate hijri) {
    return _events['${hijri.month}-${hijri.day}'];
  }

  /// Bugünün etkinliği (varsa).
  static String? today() {
    final hijri = HijriDate.fromGregorian(DateTime.now());
    return eventFor(hijri);
  }
}
