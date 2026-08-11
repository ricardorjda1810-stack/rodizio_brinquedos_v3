import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/core/config/firebase_environment.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';

void main() {
  const productionProjectId = 'rodizio-de-brinquedos';
  const productionAppId = '1:713670498412:ios:a73ec27898054ea1f2e049';
  const stagingProjectId = 'rodizio-de-brinquedos-staging';
  const stagingAppId = '1:346014753075:ios:a014794eac1aa24cf51e46';

  FirebaseOptions options({required String projectId, required String appId}) {
    return FirebaseOptions(
      apiKey: 'test-api-key',
      appId: appId,
      messagingSenderId: 'test-sender-id',
      projectId: projectId,
    );
  }

  FirebaseEnvironment resolve({
    required String configuredValue,
    required String projectId,
    required String appId,
  }) {
    return FirebaseEnvironment.resolveIos(
      configuredValue: configuredValue,
      options: options(projectId: projectId, appId: appId),
    );
  }

  test('production explícito aceita somente opções de produção', () {
    expect(
      resolve(
        configuredValue: 'production',
        projectId: productionProjectId,
        appId: productionAppId,
      ),
      FirebaseEnvironment.production,
    );
  });

  test('staging explícito aceita somente opções de staging', () {
    expect(
      resolve(
        configuredValue: 'staging',
        projectId: stagingProjectId,
        appId: stagingAppId,
      ),
      FirebaseEnvironment.staging,
    );
  });

  test('valor vazio resolve opções exatas de produção', () {
    expect(
      resolve(
        configuredValue: '',
        projectId: productionProjectId,
        appId: productionAppId,
      ),
      FirebaseEnvironment.production,
    );
  });

  test('valor vazio resolve opções exatas de staging', () {
    expect(
      resolve(
        configuredValue: '',
        projectId: stagingProjectId,
        appId: stagingAppId,
      ),
      FirebaseEnvironment.staging,
    );
  });

  test('define ausente resolve produção pelas opções nativas', () {
    expect(FirebaseEnvironment.configuredValue, isEmpty);
    expect(
      resolve(
        configuredValue: FirebaseEnvironment.configuredValue,
        projectId: productionProjectId,
        appId: productionAppId,
      ),
      FirebaseEnvironment.production,
    );
  });

  test('production explícito rejeita opções de staging', () {
    expect(
      () => resolve(
        configuredValue: 'production',
        projectId: stagingProjectId,
        appId: stagingAppId,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('staging explícito rejeita opções de produção', () {
    expect(
      () => resolve(
        configuredValue: 'staging',
        projectId: productionProjectId,
        appId: productionAppId,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('valor explícito não suportado falha fechado', () {
    expect(
      () => resolve(
        configuredValue: 'development',
        projectId: productionProjectId,
        appId: productionAppId,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('valor vazio rejeita projectId desconhecido', () {
    expect(
      () => resolve(
        configuredValue: '',
        projectId: 'unknown-project',
        appId: productionAppId,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('valor vazio rejeita appId desconhecido', () {
    expect(
      () => resolve(
        configuredValue: '',
        projectId: productionProjectId,
        appId: 'unknown-app-id',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('valor vazio rejeita opções parcialmente correspondentes', () {
    expect(
      () => resolve(
        configuredValue: '',
        projectId: productionProjectId,
        appId: stagingAppId,
      ),
      throwsA(isA<StateError>()),
    );
  });

  group('diagnósticos StoreKit usam o ambiente iOS resolvido', () {
    for (final testCase in <({
      String name,
      String configuredValue,
      String projectId,
      String appId,
      bool enabled,
    })>[
      (
        name: 'staging explícito',
        configuredValue: 'staging',
        projectId: stagingProjectId,
        appId: stagingAppId,
        enabled: true,
      ),
      (
        name: 'staging inferido pelo plist',
        configuredValue: '',
        projectId: stagingProjectId,
        appId: stagingAppId,
        enabled: true,
      ),
      (
        name: 'produção explícita',
        configuredValue: 'production',
        projectId: productionProjectId,
        appId: productionAppId,
        enabled: false,
      ),
      (
        name: 'produção inferida pelo plist',
        configuredValue: '',
        projectId: productionProjectId,
        appId: productionAppId,
        enabled: false,
      ),
    ]) {
      test(testCase.name, () {
        final environment = resolve(
          configuredValue: testCase.configuredValue,
          projectId: testCase.projectId,
          appId: testCase.appId,
        );

        expect(
          PurchaseService.storeKitDiagnosticsEnabledForEnvironment(environment),
          testCase.enabled,
        );
      });
    }
  });
}
