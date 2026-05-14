# SignalFlow

## Visão do projeto

SignalFlow é um MVP educacional e de bem-estar para explorar sinais de ativação fisiológica, sessões de pesquisa em foreground e fluxos curtos de regulação. O app mantém simulação para testes e já possui integração experimental com HealthKit para leitura de frequência cardíaca e HRV quando houver dados disponíveis.

## Objetivo

Criar uma base simples, segura e evolutiva para:

- observar amostras fisiológicas simuladas ou reais, conforme a fonte selecionada;
- estimar estados de atenção de forma explicável;
- conduzir uma regulação curta por respiração;
- registrar histórico, percepção subjetiva e sessões de pesquisa;
- coletar dados em sessões guiadas padronizadas;
- exportar dados de sessão, diagnóstico de coleta e análise temporal.

## Identidade técnica

- Nome do app: SignalFlow
- Bundle ID iOS: `com.signalflow.app`
- Coleta HealthKit: experimental, somente com o app aberto em foreground
- Background collection: não implementada

## Arquitetura

A arquitetura separa origem de dados, estado do app, motor de risco e interface:

- `data/sensors/`: abstrações e providers de sensores;
- `domain/models/`: modelos simples do domínio;
- `domain/risk_engine.dart`: cálculo explicável de score e estado;
- `app_state.dart`: estado em memória, persistência local simples e orquestração;
- `ui/`: telas e widgets.

## Simulação e sensores reais

`MockSensorProvider` mantém a simulação para desenvolvimento, demonstração e validação da experiência.

`HealthKitSensorProvider` faz leitura experimental de dados disponíveis no HealthKit:

- frequência cardíaca;
- variabilidade cardíaca HRV SDNN;
- leitura do último dado disponível;
- polling simples durante sessões de pesquisa em foreground.

Se o HealthKit não retornar dados, o app deve mostrar uma mensagem segura e continuar funcionando.

## Pesquisa guiada

O protocolo guiado organiza a coleta em fases:

1. Repouso
2. Ativação leve
3. Recuperação
4. Feedback subjetivo

Cada amostra de sessão pode registrar o rótulo da fase atual para apoiar exportação e análise posterior.

## Preparação iOS

O projeto iOS usa assinatura automática e mantém HealthKit habilitado por entitlements:

- `ios/Runner/Runner.entitlements`
- `ios/Runner/Info.plist`
- `ios/Runner.xcodeproj/project.pbxproj`

As permissões de leitura de saúde devem continuar explícitas e responsáveis. O app não grava dados de saúde neste momento.

## Princípios éticos

- O app usa linguagem de bem-estar, atenção, pesquisa e regulação.
- O app não promete prever, diagnosticar ou impedir crises.
- O usuário deve entender quando está vendo dados simulados e quando está usando HealthKit.
- Dados reais dependem do Apple Watch, do iOS e da disponibilidade no HealthKit.

## Limitações

- Não há IA ou ML.
- Não há previsão.
- Não há diagnóstico.
- Não há monitoramento contínuo em background.
- Não há notificações automáticas de saúde.
- Não há substituição de acompanhamento profissional.

Este app não realiza diagnóstico, não substitui atendimento profissional e não deve ser usado em emergências.

## Roadmap resumido

1. Validar o MVP com simulação e testes de usabilidade.
2. Melhorar a calibragem com percepção subjetiva.
3. Ampliar diagnóstico de coleta HealthKit em foreground.
4. Avaliar qualidade temporal dos dados reais.
5. Revisar privacidade e limitações técnicas antes de qualquer evolução de coleta.
