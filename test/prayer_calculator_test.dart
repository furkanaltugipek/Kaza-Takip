import 'package:flutter_test/flutter_test.dart';
import 'package:kaza_takip/core/utils/prayer_calculator.dart';
import 'package:kaza_takip/core/constants/prayer_constants.dart';

void main() {
  group('PrayerCalculator', () {
    final birthDate = DateTime(1990, 1, 1);
    final pubertyDate = DateTime(2002, 1, 1);   // 12 years old
    final regularStart = DateTime(2012, 1, 1);  // 10 years of kaza

    test('returns zero counts when regular start is before puberty', () {
      final result = PrayerCalculator.calculateKazaDebt(
        birthDate: birthDate,
        pubertyDate: pubertyDate,
        regularStartDate: pubertyDate, // same day = no debt
        isFemale: false,
      );
      for (final key in PrayerConstants.prayerKeys) {
        expect(result[key], 0);
      }
    });

    test('calculates correct debt for male', () {
      final result = PrayerCalculator.calculateKazaDebt(
        birthDate: birthDate,
        pubertyDate: pubertyDate,
        regularStartDate: regularStart,
        isFemale: false,
      );
      final days = regularStart.difference(pubertyDate).inDays;
      for (final key in PrayerConstants.prayerKeys) {
        expect(result[key], days);
      }
    });

    test('female debt is less than male due to menstrual exemption', () {
      final male = PrayerCalculator.calculateKazaDebt(
        birthDate: birthDate,
        pubertyDate: pubertyDate,
        regularStartDate: regularStart,
        isFemale: false,
      );
      final female = PrayerCalculator.calculateKazaDebt(
        birthDate: birthDate,
        pubertyDate: pubertyDate,
        regularStartDate: regularStart,
        isFemale: true,
      );
      for (final key in PrayerConstants.prayerKeys) {
        expect(female[key]! < male[key]!, isTrue);
      }
    });

    test('toRakats returns correct rakat counts', () {
      final counts = {for (final k in PrayerConstants.prayerKeys) k: 1};
      final rakats = PrayerCalculator.toRakats(counts);
      expect(rakats['fajr'], 2);
      expect(rakats['dhuhr'], 4);
      expect(rakats['asr'], 4);
      expect(rakats['maghrib'], 3);
      expect(rakats['isha'], 4);
      expect(rakats['witr'], 3);
    });

    test('totalRakatCount sums to 20 per day', () {
      final counts = {for (final k in PrayerConstants.prayerKeys) k: 1};
      expect(PrayerCalculator.totalRakatCount(counts), 20);
    });

    test('estimateCompletionDate returns null when all zero', () {
      final counts = {for (final k in PrayerConstants.prayerKeys) k: 0};
      final targets = {for (final k in PrayerConstants.prayerKeys) k: 1};
      expect(
        PrayerCalculator.estimateCompletionDate(
            kazaCounts: counts, dailyTargets: targets),
        null,
      );
    });

    test('estimateCompletionDate gives future date', () {
      final counts = {for (final k in PrayerConstants.prayerKeys) k: 365};
      final targets = {for (final k in PrayerConstants.prayerKeys) k: 1};
      final result = PrayerCalculator.estimateCompletionDate(
          kazaCounts: counts, dailyTargets: targets);
      expect(result!.isAfter(DateTime.now()), isTrue);
    });
  });
}
