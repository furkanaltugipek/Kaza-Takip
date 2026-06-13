import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/core/constants/app_constants.dart';
import 'package:kaza_takip/core/utils/date_utils.dart';
import 'package:kaza_takip/core/utils/prayer_calculator.dart';
import 'package:kaza_takip/domain/entities/daily_log.dart';
import 'package:kaza_takip/domain/entities/kaza_metrics.dart';
import 'package:kaza_takip/domain/entities/user_plan.dart';
import 'package:kaza_takip/domain/repositories/kaza_repository.dart';
import 'package:kaza_takip/domain/repositories/user_repository.dart';

part 'kaza_event.dart';
part 'kaza_state.dart';

class KazaBloc extends Bloc<KazaEvent, KazaState> {
  final KazaRepository _kazaRepo;
  final UserRepository _userRepo;

  KazaBloc({
    required KazaRepository kazaRepository,
    required UserRepository userRepository,
  })  : _kazaRepo = kazaRepository,
        _userRepo = userRepository,
        super(const KazaInitial()) {
    on<CalculateInitialDebt>(_onCalculate);
    on<SaveCalculatedDebt>(_onSave);
    on<LoadKazaMetrics>(_onLoad);
    on<TogglePrayerComplete>(_onToggle);
    on<ChangePlanMode>(_onModeChange);
    on<SyncDataWithCloud>(_onSync);
  }

  // ── Hesaplama (Sihirbaz → KazaCalculated) ───────────────────────────────────

  Future<void> _onCalculate(
      CalculateInitialDebt event, Emitter<KazaState> emit) async {
    emit(const KazaLoading());
    try {
      final result = PrayerCalculator.calculate(
        birthDate: event.birthDate,
        pubertyAge: event.pubertyAge,
        prayerStartDate: event.startDate,
        estimatedOffDays: event.offDays,
      );
      emit(KazaCalculated(result));
    } catch (e) {
      emit(KazaError('Hesaplama hatası: $e'));
    }
  }

  // ── Kaydet & Dashboard'a geç (KazaCalculated → KazaLoaded) ─────────────────

  Future<void> _onSave(
      SaveCalculatedDebt event, Emitter<KazaState> emit) async {
    final calculated = state;
    if (calculated is! KazaCalculated) return;

    emit(const KazaLoading());
    try {
      final userId = await _userRepo.getOrCreateAnonymousUserId();
      final breakdown = calculated.result.breakdown;

      // Toplam borçları metriğe aktar — tamamlanan sıfır başlıyor.
      final metrics = KazaMetrics(
        totalDebts: Map<String, int>.from(breakdown),
        completedDebts: {for (final k in breakdown.keys) k: 0},
      );
      await _kazaRepo.saveMetrics(userId, metrics);

      // Moda göre tahmini bitiş tarihini hesapla.
      const defaultTarget = 2;
      final finishDate = PrayerCalculator.estimateCompletionDate(
        remaining: breakdown,
        dailyTargetPerVakit: defaultTarget,
      );
      if (finishDate != null) {
        await _kazaRepo.saveUserPlan(
          userId,
          UserPlan(
            targetMonths: 12,
            dailyTargetPerVakit: defaultTarget,
            estimatedFinishDate: finishDate,
          ),
        );
      }

      // Yüklü duruma geç.
      add(LoadKazaMetrics(userId));
    } catch (e) {
      emit(KazaError('Kaydetme hatası: $e'));
    }
  }

  // ── Yükleme (Hive → KazaLoaded) ─────────────────────────────────────────────

  Future<void> _onLoad(
      LoadKazaMetrics event, Emitter<KazaState> emit) async {
    emit(const KazaLoading());
    try {
      final metrics = await _kazaRepo.getMetrics(event.userId);
      final plan = await _kazaRepo.getUserPlan(event.userId);
      final todayLogs =
          await _kazaRepo.getDailyLogs(event.userId, DateTime.now());
      final today = todayLogs
          .where((l) => AppDateUtils.isSameDay(l.date, DateTime.now()))
          .firstOrNull;

      emit(KazaLoaded(
        userId: event.userId,
        metrics: metrics,
        todayLog: today,
        userPlan: plan,
        pendingChanges: _kazaRepo.pendingChanges(event.userId),
      ));
    } catch (e) {
      emit(KazaError('Yükleme hatası: $e'));
    }
  }

  // ── Vakit tamamlama (anlık Hive yazması — ağ YOK) ───────────────────────────

  Future<void> _onToggle(
      TogglePrayerComplete event, Emitter<KazaState> emit) async {
    final loaded = state;
    if (loaded is! KazaLoaded) return;

    try {
      // 1. Metriği Hive'da güncelle (anlık, senkron).
      final updated = await _kazaRepo.updateKazaProgress(
        userId: loaded.userId,
        vakitKey: event.prayerVakit,
        delta: event.amount,
      );

      // 2. Günlük kaydı güncelle.
      final todayCompleted = Map<String, int>.from(
          loaded.todayLog?.completedToday ??
              {for (final k in updated.totalDebts.keys) k: 0});
      todayCompleted[event.prayerVakit] =
          ((todayCompleted[event.prayerVakit] ?? 0) + event.amount)
              .clamp(0, loaded.dailyTargetPerVakit);

      final newLog = DailyLog.fromCounts(
        date: AppDateUtils.today(),
        completedToday: todayCompleted,
        targetCount:
            loaded.dailyTargetPerVakit * updated.totalDebts.length,
      );
      await _kazaRepo.saveDailyLog(loaded.userId, newLog);

      // 3. UI'yı anlık güncelle — ağ çağrısı yok.
      emit(loaded.copyWith(
        metrics: updated,
        todayLog: newLog,
        pendingChanges: _kazaRepo.pendingChanges(loaded.userId),
      ));

      // 4. Eşiğe ulaşıldıysa otomatik senkronize et.
      if (_kazaRepo.pendingChanges(loaded.userId) >=
          AppConstants.firestoreSyncThreshold) {
        add(const SyncDataWithCloud());
      }
    } catch (e) {
      emit(KazaError('Güncelleme hatası: $e'));
    }
  }

  // ── Mod değişikliği ──────────────────────────────────────────────────────────

  Future<void> _onModeChange(
      ChangePlanMode event, Emitter<KazaState> emit) async {
    final loaded = state;
    if (loaded is! KazaLoaded) return;

    final newTarget = switch (event.mode) {
      'EASY' => 1,
      'HARD' => 4,
      _ => 2,
    };

    // Tahmini bitiş tarihini yeni moda göre yeniden hesapla.
    final finishDate = PrayerCalculator.estimateCompletionDate(
      remaining: loaded.metrics.remainingDebts,
      dailyTargetPerVakit: newTarget,
    );
    final updatedPlan = (loaded.userPlan ?? UserPlan.initial()).copyWith(
      dailyTargetPerVakit: newTarget,
      estimatedFinishDate: finishDate,
    );
    await _kazaRepo.saveUserPlan(loaded.userId, updatedPlan);
    emit(loaded.copyWith(planMode: event.mode, userPlan: updatedPlan));
  }

  // ── Bulut senkronu (tek batch) ───────────────────────────────────────────────

  Future<void> _onSync(
      SyncDataWithCloud event, Emitter<KazaState> emit) async {
    final loaded = state;
    if (loaded is! KazaLoaded) return;
    try {
      await _kazaRepo.syncWithCloud(loaded.userId);
      emit(loaded.copyWith(pendingChanges: 0));
    } catch (_) {
      // Senkronizasyon başarısız → sessizce devam et, yerel veri sağlam.
    }
  }
}

