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
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _toyRepository = ToyRepository(_db);
    _roundRepository = RoundRepository(_db);
    _settingsRepository = SettingsRepository(_db);
    _initFuture = _runInitialization();
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
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return _BootstrapErrorScreen(
            onRetry: () {
              setState(() {
                _initFuture = _runInitialization();
              });
            },
            error: snapshot.error?.toString(),
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

  Future<void> _runInitialization() async {
    await _toyRepository.ensureSeedData();
    await _settingsRepository.load();
  }
}

class _BootstrapErrorScreen extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const _BootstrapErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 46,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Falha ao iniciar o aplicativo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (error ?? 'Erro desconhecido').trim(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

