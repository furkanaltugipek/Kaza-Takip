import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaza_takip/domain/entities/kaza_debt.dart';
import 'package:kaza_takip/domain/entities/prayer_plan.dart';
import 'package:kaza_takip/domain/entities/streak.dart';
import 'package:kaza_takip/domain/repositories/kaza_repository.dart';
import 'package:kaza_takip/domain/usecases/complete_prayer.dart';
import 'package:kaza_takip/domain/usecases/get_today_plan.dart';
import 'package:kaza_takip/domain/usecases/get_streak.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final KazaRepository _kazaRepository;
  final GetTodayPlan _getTodayPlan;
  final CompletePrayer _completePrayer;
  final GetStreak _getStreak;

  late String _userId;

  DashboardBloc({
    required KazaRepository kazaRepository,
    required GetTodayPlan getTodayPlan,
    required CompletePrayer completePrayer,
    required GetStreak getStreak,
  })  : _kazaRepository = kazaRepository,
        _getTodayPlan = getTodayPlan,
        _completePrayer = completePrayer,
        _getStreak = getStreak,
        super(const DashboardState()) {
    on<DashboardLoaded>(_onLoaded);
    on<DashboardPrayerCompleted>(_onPrayerCompleted);
    on<DashboardModeChanged>(_onModeChanged);
    on<DashboardSyncRequested>(_onSyncRequested);
  }

  Future<void> _onLoaded(
      DashboardLoaded event, Emitter<DashboardState> emit) async {
    _userId = event.userId;
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final debt = await _kazaRepository.getKazaDebt(_userId);
      final streak = await _getStreak(_userId);
      if (debt == null) {
        emit(state.copyWith(
          status: DashboardStatus.loaded,
          streak: streak,
        ));
        return;
      }
      final plan = await _getTodayPlan(
        userId: _userId,
        mode: state.mode,
        debt: debt,
      );
      emit(state.copyWith(
        status: DashboardStatus.loaded,
        todayPlan: plan,
        kazaDebt: debt,
        streak: streak,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: DashboardStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onPrayerCompleted(
      DashboardPrayerCompleted event, Emitter<DashboardState> emit) async {
    if (state.todayPlan == null || state.kazaDebt == null) return;
    try {
      final result = await _completePrayer(
        userId: _userId,
        plan: state.todayPlan!,
        debt: state.kazaDebt!,
        streak: state.streak ?? Streak(userId: _userId),
        slotId: event.slotId,
      );
      emit(state.copyWith(
        todayPlan: result.plan,
        kazaDebt: result.debt,
        streak: result.streak,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onModeChanged(
      DashboardModeChanged event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(mode: event.mode));
    if (state.kazaDebt != null) {
      add(DashboardLoaded(_userId));
    }
  }

  Future<void> _onSyncRequested(
      DashboardSyncRequested event, Emitter<DashboardState> emit) async {
    await _kazaRepository.syncToRemote(_userId);
  }
}
