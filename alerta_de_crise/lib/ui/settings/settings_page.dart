import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/sensors/sensor_provider.dart';
import '../../domain/models/sensitivity_level.dart';
import '../theme/ui_tokens.dart';

final class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(UiTokens.m),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(UiTokens.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Simulação',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  Text(
                    appState.isSimulationRunning
                        ? 'Status: ativa'
                        : 'Status: inativa',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                  const SizedBox(height: UiTokens.m),
                  FilledButton(
                    onPressed: appState.isSimulationRunning
                        ? appState.stopSimulation
                        : appState.startSimulation,
                    child: Text(
                      appState.isSimulationRunning
                          ? 'Parar simulação'
                          : 'Iniciar simulação',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: UiTokens.m),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(UiTokens.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fonte de dados',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  const Text(
                    'Escolha a origem das amostras usadas pelo protótipo.',
                    style: TextStyle(color: UiTokens.textSoft, height: 1.35),
                  ),
                  const SizedBox(height: UiTokens.m),
                  Text(
                    'Fonte selecionada: ${appState.sensorProviderType.label}',
                    style: const TextStyle(
                      color: UiTokens.textSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  Text(
                    'Permissão: ${appState.dataSourcePermissionMessage}',
                    style: const TextStyle(
                      color: UiTokens.textSoft,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: UiTokens.m),
                  SegmentedButton<SensorProviderType>(
                    segments: SensorProviderType.values
                        .map(
                          (type) => ButtonSegment<SensorProviderType>(
                            value: type,
                            label: Text(type.label),
                          ),
                        )
                        .toList(),
                    selected: {appState.sensorProviderType},
                    onSelectionChanged: (selection) {
                      appState.updateSensorProvider(selection.first);
                    },
                  ),
                  const SizedBox(height: UiTokens.m),
                  OutlinedButton(
                    onPressed: () async {
                      await appState.requestCurrentProviderPermissions();
                    },
                    child: const Text('Solicitar permissão'),
                  ),
                  if (appState.isHealthKitInPreparation) ...[
                    const SizedBox(height: UiTokens.m),
                    const Text(
                      'A integração HealthKit está em preparação. Nesta versão, a coleta real ainda não foi ativada.',
                      style: TextStyle(color: UiTokens.textSoft, height: 1.35),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: UiTokens.m),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(UiTokens.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sensibilidade',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.m),
                  SegmentedButton<SensitivityLevel>(
                    segments: SensitivityLevel.values
                        .map(
                          (level) => ButtonSegment<SensitivityLevel>(
                            value: level,
                            label: Text(level.label),
                          ),
                        )
                        .toList(),
                    selected: {appState.sensitivity},
                    onSelectionChanged: (selection) {
                      appState.updateSensitivity(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: UiTokens.m),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(UiTokens.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Dados locais',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.m),
                  OutlinedButton(
                    onPressed: () => _confirmClearHistory(context, appState),
                    child: const Text('Limpar histórico'),
                  ),
                  const SizedBox(height: UiTokens.s),
                  OutlinedButton(
                    onPressed: () => _resetOnboarding(context, appState),
                    child: const Text('Resetar onboarding'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory(
    BuildContext context,
    AppState appState,
  ) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpar histórico?'),
          content: const Text(
            'Eventos do histórico, percepções subjetivas e sessões de pesquisa salvos neste aparelho serão removidos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Limpar'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !context.mounted) {
      return;
    }

    await appState.clearHistory();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Histórico limpo')));
  }

  Future<void> _resetOnboarding(BuildContext context, AppState appState) async {
    await appState.resetOnboarding();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Onboarding será exibido na próxima abertura'),
      ),
    );
  }
}
