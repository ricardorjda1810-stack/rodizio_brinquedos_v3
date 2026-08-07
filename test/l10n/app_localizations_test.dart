import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/services/app_trial_service.dart';

void main() {
  group('AppLocalizations', () {
    test('localizes trial banner, round status, categories, and demo toys', () {
      const l10n = AppLocalizations(Locale('en', 'US'));
      final now = DateTime(2026, 1, 1, 8);
      final status = AppTrialStatus(
        startedAt: now,
        endsAt: now.add(const Duration(days: 7)),
        lastSeenAt: now,
        effectiveNow: now,
        trialUsed: true,
        introPending: false,
      );

      expect(
        l10n.trialHomeNotice(status),
        'Free trial active — 7 days remaining',
      );
      expect(l10n.roundReadyToStart, 'Ready to start');
      expect(
        l10n.categoryNameById('corpo', 'Corpo e Respiração'),
        'Body and Breathing',
      );
      expect(
        l10n.categoryNameById('exploracao', 'Sentidos e Exploração'),
        'Senses and Exploration',
      );
      expect(
        l10n.categoryNameById('maos', 'Mãos e Construção'),
        'Hands and Building',
      );
      expect(
        l10n.categoryNameById('imaginacao', 'Imaginação e Criatividade'),
        'Imagination and Creativity',
      );
      expect(
        l10n.categoryNameById('comunicacao', 'Comunicação e Histórias'),
        'Communication and Stories',
      );
      expect(
        l10n.toyDisplayNameForId(
          id: 'demo_toy_corpo_bola_macia',
          name: 'Bola macia',
        ),
        'Soft ball',
      );
      expect(l10n.renameBox, 'Rename box');
      expect(l10n.boxName, 'Box name');
      expect(l10n.boxNameRequired, 'Enter a box name.');
      expect(l10n.boxRenamed, 'Box renamed.');
      expect(l10n.backToHome, 'Back to Home');
    });

    test('preserves user-created toy names in en-US', () {
      const l10n = AppLocalizations(Locale('en', 'US'));

      expect(l10n.toyDisplayName('Bola macia'), 'Bola macia');
      expect(
        l10n.toyDisplayNameForId(id: 'user_toy_123', name: 'Bola macia'),
        'Bola macia',
      );
    });

    test('keeps pt-BR official copy unchanged', () {
      const l10n = AppLocalizations(Locale('pt', 'BR'));
      final now = DateTime(2026, 1, 1, 8);
      final status = AppTrialStatus(
        startedAt: now,
        endsAt: now.add(const Duration(days: 7)),
        lastSeenAt: now,
        effectiveNow: now,
        trialUsed: true,
        introPending: false,
      );

      expect(
          l10n.trialHomeNotice(status), 'Teste grátis ativo — faltam 7 dias');
      expect(l10n.roundReadyToStart, 'Pronta para iniciar');
      expect(
        l10n.categoryNameById('corpo', 'Corpo e Respiração'),
        'Corpo e Respiração',
      );
      expect(
        l10n.toyDisplayNameForId(
          id: 'demo_toy_corpo_bola_macia',
          name: 'Bola macia',
        ),
        'Bola macia',
      );
      expect(l10n.renameBox, 'Renomear caixa');
      expect(l10n.boxName, 'Nome da caixa');
      expect(l10n.boxNameRequired, 'Informe o nome da caixa.');
      expect(l10n.boxRenamed, 'Caixa renomeada.');
      expect(l10n.backToHome, 'Voltar ao início');
    });

    test('formats app version in pt-BR without unsafe placeholders', () {
      const l10n = AppLocalizations(Locale('pt', 'BR'));

      expect(l10n.appVersionLabel('1.0.11', '121'), 'Versão 1.0.11 (121)');
      expect(l10n.appVersionLabel('1.0.11', ''), 'Versão 1.0.11');
      expect(l10n.appVersionLabel('', '121'), 'Versão indisponível');
      expect(l10n.appVersionLabel('', ''), 'Versão indisponível');
      expect(l10n.appVersionLoading, 'Versão —');
      expect(l10n.appVersionLabel('1.0.11', ''), isNot(contains('()')));
      expect(l10n.appVersionLabel('', ''), isNot(contains('null')));
    });

    test('formats app version in en-US and supports future builds', () {
      const l10n = AppLocalizations(Locale('en', 'US'));

      expect(l10n.appVersionLabel('1.0.11', '121'), 'Version 1.0.11 (121)');
      expect(l10n.appVersionLabel('1.0.11', ''), 'Version 1.0.11');
      expect(l10n.appVersionLabel('', '121'), 'Version unavailable');
      expect(l10n.appVersionLabel('', ''), 'Version unavailable');
      expect(l10n.appVersionLoading, 'Version —');
      expect(l10n.appVersionLabel('1.0.11', '122'), 'Version 1.0.11 (122)');
    });
  });
}
