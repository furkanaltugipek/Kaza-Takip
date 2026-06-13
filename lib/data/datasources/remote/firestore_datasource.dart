import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaza_takip/core/constants/app_constants.dart';
import 'package:kaza_takip/data/models/kaza_debt_model.dart';
import 'package:kaza_takip/data/models/prayer_plan_model.dart';

/// All Firestore writes are batched.
/// This datasource is called ONLY when syncToRemote() is triggered.
class FirestoreDataSource {
  final FirebaseFirestore _db;

  FirestoreDataSource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── KazaDebt ──────────────────────────────────────────────────────────────

  Future<KazaDebtModel?> getKazaDebt(String userId) async {
    final doc = await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection(AppConstants.colKazaDebts)
        .doc('debt')
        .get();
    if (!doc.exists) return null;
    return KazaDebtModel.fromFirestore(doc.data()!);
  }

  Future<void> syncKazaDebt(KazaDebtModel model) =>
      _db
          .collection(AppConstants.colUsers)
          .doc(model.userId)
          .collection(AppConstants.colKazaDebts)
          .doc('debt')
          .set(model.toFirestore(), SetOptions(merge: true));

  // ── DailyPlans ────────────────────────────────────────────────────────────

  Future<void> syncDailyPlans(
      String userId, List<PrayerPlanModel> plans) async {
    final batch = _db.batch();
    for (final plan in plans) {
      final ref = _db
          .collection(AppConstants.colUsers)
          .doc(userId)
          .collection(AppConstants.colDailyPlans)
          .doc(plan.date.toIso8601String().substring(0, 10));
      batch.set(ref, plan.toFirestore(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  // ── Calendar Data ─────────────────────────────────────────────────────────

  Future<Map<String, double>> getCalendarData(
      String userId, DateTime month) async {
    final start =
        DateTime(month.year, month.month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(month.year, month.month + 1, 0)
        .toIso8601String()
        .substring(0, 10);

    final snap = await _db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection(AppConstants.colDailyPlans)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: start)
        .where(FieldPath.documentId, isLessThanOrEqualTo: end)
        .get();

    final result = <String, double>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      final slots = (data['slots'] as List?) ?? [];
      if (slots.isEmpty) continue;
      final completed = slots.where((s) => s['isCompleted'] == true).length;
      result[doc.id] = completed / slots.length;
    }
    return result;
  }

  // ── User Profile ──────────────────────────────────────────────────────────

  Future<void> syncUserProfile(Map<String, dynamic> data, String userId) =>
      _db
          .collection(AppConstants.colUsers)
          .doc(userId)
          .set(data, SetOptions(merge: true));
}
