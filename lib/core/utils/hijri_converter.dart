/// Lightweight, dependency-free Hijri (Islamic) calendar converter.
///
/// Uses the Kuwaiti tabular algorithm — accurate enough for daily display and
/// fully offline (no network, no extra package required).
class HijriDate {
  final int year;
  final int month; // 1..12
  final int day;   // 1..30

  const HijriDate(this.year, this.month, this.day);

  /// Türkçe ay adları — Diyanet kullanımına uygun.
  static const List<String> monthNamesTr = [
    'Muharrem',
    'Safer',
    'Rebiülevvel',
    'Rebiülahir',
    'Cemaziyelevvel',
    'Cemaziyelahir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce',
  ];

  String get monthNameTr => monthNamesTr[month - 1];

  /// "4 Muharrem 1448" gibi biçimlendirilmiş çıktı.
  String formatTr() => '$day $monthNameTr $year';

  /// Gregoryen tarihi Hicri'ye çevirir.
  factory HijriDate.fromGregorian(DateTime g) {
    final jd = _gregorianToJD(g.year, g.month, g.day);
    return _jdToHijri(jd);
  }

  static int _gregorianToJD(int year, int month, int day) {
    int y = year;
    int m = month;
    if (m < 3) {
      y -= 1;
      m += 12;
    }
    final a = y ~/ 100;
    final b = 2 - a + (a ~/ 4);
    return ((365.25 * (y + 4716)).floor()) +
        ((30.6001 * (m + 1)).floor()) +
        day +
        b -
        1524;
  }

  static HijriDate _jdToHijri(int jd) {
    int l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l) ~/ 709;
    final day = l - ((709 * month) ~/ 24);
    final year = 30 * n + j - 30;
    return HijriDate(year, month, day);
  }
}
