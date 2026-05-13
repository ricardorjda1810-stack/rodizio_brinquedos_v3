# Alerta de Crise

## Visão do projeto

Alerta de Crise é um MVP educacional e de bem-estar para explorar sinais de ativação fisiológica e fluxos curtos de regulação. Nesta fase, o app usa dados simulados para validar UI, histórico, pesquisa, calibragem subjetiva e exportação.

## Objetivo

Criar uma base simples, segura e evolutiva para:

- observar amostras fisiológicas simuladas;
- estimar estados de atenção de forma explicável;
- conduzir uma regulação curta por respiração;
- registrar histórico, percepção subjetiva e sessões de pesquisa;
- preparar uma futura integração com sensores reais do ecossistema iOS/Apple Watch.

## Arquitetura

A arquitetura separa origem de dados, estado do app, motor de risco e interface:

- `data/sensors/`: abstrações e providers de sensores;
- `domain/models/`: modelos simples do domínio;
- `domain/risk_engine.dart`: cálculo explicável de score e estado;
- `app_state.dart`: estado em memória, persistência local simples e orquestração;
- `ui/`: telas e widgets.

## Simulação e sensores reais

Hoje, a fonte principal é `MockSensorProvider`, que gera amostras simuladas de FC, HRV e movimento.

`HealthKitSensorProvider` existe apenas como preparação arquitetural. Ele ainda não lê dados reais, não solicita permissões e não acessa Apple Watch ou HealthKit nesta etapa.

## Preparação iOS

A pasta `ios/` permanece com a configuração padrão criada pelo Flutter. Capacidades como HealthKit, permissões de leitura e entitlements específicos devem ser adicionados somente quando a coleta real for implementada e revisada.

Nesta etapa, a preparação fica limitada à arquitetura Dart:

- `SensorProvider` define o contrato;
- `MockSensorProvider` mantém a simulação;
- `HealthKitSensorProvider` documenta os próximos pontos de integração sem acessar dados reais.

## Princípios éticos

- O app usa linguagem de bem-estar, atenção e regulação.
- O app não promete prever, diagnosticar ou impedir crises.
- O usuário deve entender quando está vendo dados simulados.
- Qualquer integração futura com dados reais deve pedir permissões claras e explicar o uso dos dados.

## Limitações

- Não há leitura real de sensores nesta versão.
- Não há IA ou ML.
- Não há diagnóstico.
- Não há monitoramento contínuo em background.
- Não há substituição de acompanhamento profissional.

Este app não realiza diagnóstico, não substitui atendimento profissional e não deve ser usado em emergências.

## Roadmap resumido

1. Validar o MVP com simulação e testes de usabilidade.
2. Melhorar a calibragem com percepção subjetiva.
3. Implementar permissões HealthKit de forma explícita.
4. Ler FC e HRV reais somente após revisão de privacidade.
5. Avaliar limitações técnicas do Apple Watch/iOS antes de qualquer coleta contínua.
