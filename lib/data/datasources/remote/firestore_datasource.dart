import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kaza_takip/core/constants/app_constants.dart';
import 'package:kaza_takip/data/models/daily_log_model.dart';
import 'package:kaza_takip/data/models/kaza_debt_model.dart';
import 'package:kaza_takip/data/models/kaza_metrics_model.dart';
import 'package:kaza_takip/data/models/prayer_plan_model.dart';
import 'package:kaza_takip/data/models/user_plan_model.dart';

/// Tüm Firestore yazmaları toplu (batch) yapılır.
/// Firebase yoksa tüm metotlar sessizce no-op döner (offline-first).
class FirestoreDataSource {
  FirebaseFirestore? get _db {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<void> syncUserData({
    required String userId,
    KazaMetricsModel? metrics,
    List<DailyLogModel> dailyLogs = const [],
    UserPlanModel? plan,
  }) async {
    final db = _db;
    if (db == null) return;

    final batch = db.batch();
    final userDoc = db.collection(AppConstants.colUsers).doc(userId);

    if (metrics != null) {
      batch.set(userDoc.collection('metrics').doc('current'),
          metrics.toJson(), SetOptions(merge: true));
    }

    if (plan != null) {
      batch.set(userDoc.collection('plan').doc('current'), plan.toJson(),
          SetOptions(merge: true));
    }

    for (final log in dailyLogs) {
      batch.set(
        userDoc.collection(AppConstants.colDailyPlans).doc(log.dateKey),
        log.toJson(),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<KazaMetricsModel?> getMetrics(String userId) async {
    final db = _db;
    if (db == null) return null;
    final doc = await db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection('metrics')
        .doc('current')
        .get();
    if (!doc.exists) return null;
    return KazaMetricsModel.fromJson(doc.data()!);
  }

  Future<List<DailyLogModel>> getDailyLogs(
      String userId, DateTime month) async {
    final db = _db;
    if (db == null) return [];
    final start =
        DateTime(month.year, month.month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(month.year, month.month + 1, 0)
        .toIso8601String()
        .substring(0, 10);

    final snap = await db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection(AppConstants.colDailyPlans)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: start)
        .where(FieldPath.documentId, isLessThanOrEqualTo: end)
        .get();

    return snap.docs.map((d) => DailyLogModel.fromJson(d.data())).toList();
  }

  Future<KazaDebtModel?> getKazaDebt(String userId) async {
    final db = _db;
    if (db == null) return null;
    final doc = await db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .collection(AppConstants.colKazaDebts)
        .doc('debt')
        .get();
    if (!doc.exists) return null;
    return KazaDebtModel.fromFirestore(doc.data()!);
  }

  Future<void> syncKazaDebt(KazaDebtModel model) async {
    final db = _db;
    if (db == null) return;
    await db
        .collection(AppConstants.colUsers)
        .doc(model.userId)
        .collection(AppConstants.colKazaDebts)
        .doc('debt')
        .set(model.toFirestore(), SetOptions(merge: true));
  }

  Future<void> syncDailyPlans(
      String userId, List<PrayerPlanModel> plans) async {
    final db = _db;
    if (db == null) return;
    final batch = db.batch();
    for (final plan in plans) {
      final ref = db
          .collection(AppConstants.colUsers)
          .doc(userId)
          .collection(AppConstants.colDailyPlans)
          .doc(plan.date.toIso8601String().substring(0, 10));
      batch.set(ref, plan.toFirestore(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<Map<String, double>> getCalendarData(
      String userId, DateTime month) async {
    final db = _db;
    if (db == null) return {};
    final start =
        DateTime(month.year, month.month, 1).toIso8601String().substring(0, 10);
    final end = DateTime(month.year, month.month + 1, 0)
        .toIso8601String()
        .substring(0, 10);

    final snap = await db
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

  Future<void> syncUserProfile(Map<String, dynamic> data, String userId) async {
    final db = _db;
    if (db == null) return;
    await db
        .collection(AppConstants.colUsers)
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }
}
