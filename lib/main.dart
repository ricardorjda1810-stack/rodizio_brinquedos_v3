// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:rodizio_brinquedos_v3/bootstrap.dart'
    if (dart.library.html) 'package:rodizio_brinquedos_v3/bootstrap_web.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebaseAnalytics();
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';
  runApp(const Bootstrap());
}

Future<void> _initializeFirebaseAnalytics() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await AppAnalytics.logAppOpen();
  } catch (error) {
    debugPrint('Firebase initialization skipped: $error');
  }
}
