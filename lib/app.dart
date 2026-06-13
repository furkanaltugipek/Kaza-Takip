import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaza_takip/core/di/injection_container.dart';
import 'package:kaza_takip/core/theme/app_theme.dart';
import 'package:kaza_takip/domain/repositories/user_repository.dart';
import 'package:kaza_takip/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:kaza_takip/presentation/bloc/kaza_calculator/kaza_calculator_bloc.dart';
import 'package:kaza_takip/presentation/bloc/simulator/simulator_bloc.dart';
import 'package:kaza_takip/presentation/pages/dashboard/dashboard_page.dart';

class KazaTakipApp extends StatefulWidget {
  const KazaTakipApp({super.key});

  @override
  State<KazaTakipApp> createState() => _KazaTakipAppState();
}

class _KazaTakipAppState extends State<KazaTakipApp> {
  late final Future<String> _userIdFuture;

  @override
  void initState() {
    super.initState();
    _userIdFuture = sl<UserRepository>().getOrCreateAnonymousUserId();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _userIdFuture,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final userId = snap.data!;
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => sl<KazaCalculatorBloc>()
                ..add(KazaCalculatorStarted(userId)),
            ),
            BlocProvider(
              create: (_) =>
                  sl<DashboardBloc>()..add(DashboardLoaded(userId)),
            ),
            BlocProvider(create: (_) => sl<SimulatorBloc>()),
          ],
          child: MaterialApp(
            title: 'Kaza Takip',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr'),
              Locale('en'),
            ],
            home: const DashboardPage(),
          ),
        );
      },
    );
  }
}
