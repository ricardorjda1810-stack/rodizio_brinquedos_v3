// lib/bootstrap.dart
import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/app.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});

  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  late final AppDatabase _db;
  late final ToyRepository _toyRepository;
  late final RoundRepository _roundRepository;
  late final SettingsRepository _settingsRepository;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _toyRepository = ToyRepository(_db);
    _roundRepository = RoundRepository(_db);
    _settingsRepository = SettingsRepository(_db);
    _initFuture = () async {
      await _toyRepository.ensureSeedData();
      await _settingsRepository.load();
    }();
  }

  @override
  void dispose() {
    _settingsRepository.dispose(); // ✅ fecha streams
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return App(
          toyRepository: _toyRepository,
          roundRepository: _roundRepository,
          settingsRepository: _settingsRepository,
        );
      },
    );
  }
}

