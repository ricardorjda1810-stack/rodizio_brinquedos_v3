import 'package:flutter/material.dart';

import '../../database/audit/database_health_report.dart';
import '../../database/audit/database_integrity_service.dart';
import '../../database/audit/database_migration_service.dart';

class DatabaseAuditDebugPage extends StatefulWidget {
  const DatabaseAuditDebugPage({super.key});

  @override
  State<DatabaseAuditDebugPage> createState() => _DatabaseAuditDebugPageState();
}

class _DatabaseAuditDebugPageState extends State<DatabaseAuditDebugPage> {
  final DatabaseIntegrityService _integrityService = DatabaseIntegrityService();
  final DatabaseMigrationService _migrationService = DatabaseMigrationService();

  DatabaseHealthReport? _report;
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    final report = _report;

    return Scaffold(
      appBar: AppBar(title: const Text('Database Audit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Auditoria técnica local',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Verifica schema, integridade, JSON serializado e consistência '
            'temporal dos dados locais do SignalFlow.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isRunning ? null : _runAudit,
            child: Text(_isRunning ? 'Auditando...' : 'Rodar auditoria'),
          ),
          const SizedBox(height: 16),
          Text('Schema version: ${_migrationService.currentSchemaVersion}'),
          Text(
            'Migrations registradas: '
            '${_migrationService.registeredMigrations.length}',
          ),
          const SizedBox(height: 16),
          if (report == null)
            const Text('Nenhuma auditoria executada nesta sessão debug.')
          else
            _ReportView(report: report),
        ],
      ),
    );
  }

  Future<void> _runAudit() async {
    setState(() => _isRunning = true);
    final report = await _integrityService.runIntegrityAudit();
    if (!mounted) return;
    setState(() {
      _report = report;
      _isRunning = false;
    });
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.report});

  final DatabaseHealthReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.isHealthy ? 'Database integrity OK' : 'Issues encontrados',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text('Gerado em: ${report.generatedAt.toIso8601String()}'),
        Text('Schema version: ${report.schemaVersion}'),
        Text('Tabelas verificadas: ${report.tablesChecked.length}'),
        Text('Total de registros: ${report.totalRecords}'),
        Text('Health score: ${report.healthScore}'),
        const SizedBox(height: 12),
        Text('Issues', style: Theme.of(context).textTheme.titleSmall),
        if (report.issues.isEmpty)
          const Text('Nenhum issue encontrado.')
        else
          for (final issue in report.issues) Text('- $issue'),
        const SizedBox(height: 12),
        Text('Warnings', style: Theme.of(context).textTheme.titleSmall),
        if (report.warnings.isEmpty)
          const Text('Nenhum warning encontrado.')
        else
          for (final warning in report.warnings) Text('- $warning'),
      ],
    );
  }
}
