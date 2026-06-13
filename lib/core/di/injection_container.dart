import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kaza_takip/data/datasources/local/hive_datasource.dart';
import 'package:kaza_takip/data/datasources/remote/firestore_datasource.dart';
import 'package:kaza_takip/data/repositories/kaza_repository_impl.dart';
import 'package:kaza_takip/data/repositories/user_repository_impl.dart';
import 'package:kaza_takip/domain/repositories/kaza_repository.dart';
import 'package:kaza_takip/domain/repositories/user_repository.dart';
import 'package:kaza_takip/domain/usecases/calculate_kaza_debt.dart';
import 'package:kaza_takip/domain/usecases/complete_prayer.dart';
import 'package:kaza_takip/domain/usecases/get_streak.dart';
import 'package:kaza_takip/domain/usecases/get_today_plan.dart';
import 'package:kaza_takip/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:kaza_takip/presentation/bloc/kaza_calculator/kaza_calculator_bloc.dart';
import 'package:kaza_takip/presentation/bloc/simulator/simulator_bloc.dart';
import 'package:kaza_takip/presentation/blocs/kaza/kaza_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ──────────────────────────────────────────────────────────────
  final hive = HiveLocalDataSource();
  await hive.init();
  sl.registerSingleton<HiveLocalDataSource>(hive);

  sl.registerSingleton<FirestoreDataSource>(FirestoreDataSource());

  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<KazaRepository>(() => KazaRepositoryImpl(
        local: sl(),
        remote: sl(),
      ));

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
        local: sl(),
        remote: sl(),
        prefs: sl(),
      ));

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => CalculateKazaDebt(sl()));
  sl.registerLazySingleton(() => GetTodayPlan(sl()));
  sl.registerLazySingleton(() => CompletePrayer(sl()));
  sl.registerLazySingleton(() => GetStreak(sl()));

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory(() => KazaCalculatorBloc(calculateKazaDebt: sl()));
  sl.registerFactory(() => DashboardBloc(
        kazaRepository: sl(),
        getTodayPlan: sl(),
        completePrayer: sl(),
        getStreak: sl(),
      ));
  sl.registerFactory(() => SimulatorBloc());

  // ── Yeni birleşik KazaBloc ────────────────────────────────────────────────
  sl.registerFactory(() => KazaBloc(
        kazaRepository: sl(),
        userRepository: sl(),
      ));
}
