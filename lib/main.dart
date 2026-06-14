import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kaza_takip/app.dart';
import 'package:kaza_takip/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dikey moda kilitle
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Türkçe tarih biçimlendirme verisini yükle (intl + table_calendar için).
  await initializeDateFormatting('tr_TR', null);

  // Firebase başlatma — yapılandırma yoksa uygulama yerel modda çalışmaya
  // devam eder (offline-first).
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // firebase_options yoksa sessizce geç; tüm veriler Hive'da yerel tutulur.
  }

  await initDependencies();

  runApp(const KazaTakipApp());
}
