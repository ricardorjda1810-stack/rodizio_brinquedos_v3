import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/core/config/firebase_environment.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';

class Bootstrap extends StatelessWidget {
  const Bootstrap({super.key, required this.firebaseEnvironment});

  final FirebaseEnvironment? firebaseEnvironment;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(title: const Text('Rodízio de Brinquedos')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Versão mobile no momento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Esta versão do app está configurada para rodar em Android/iOS apenas.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
