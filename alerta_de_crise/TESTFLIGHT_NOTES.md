# SignalFlow - TestFlight Notes

## Visão do app

SignalFlow é um app experimental de bem-estar e pesquisa pessoal para acompanhar sinais fisiológicos em sessões guiadas. O app combina simulação local, leitura HealthKit em foreground e protocolos guiados para observar variações de frequência cardíaca e HRV quando esses dados estiverem disponíveis.

SignalFlow não realiza diagnóstico, não prevê crises e não substitui atendimento profissional.

## Funcionalidades atuais

- Onboarding com linguagem responsável.
- Fonte de dados por simulação para testes sem HealthKit.
- Fonte HealthKit experimental para frequência cardíaca e HRV SDNN.
- Leitura do último dado HealthKit disponível.
- Coleta HealthKit por sessão enquanto o app está aberto em foreground.
- Modo pesquisa com export CSV de amostras da sessão.
- Diagnóstico de coleta HealthKit.
- Análise temporal da coleta.
- Protocolo guiado com fases de repouso, ativação leve, recuperação e feedback subjetivo.
- Análise comparativa por fase do protocolo guiado.

## Limitações conhecidas

- A coleta HealthKit é foreground only.
- Não há coleta em background.
- A disponibilidade de dados depende do Apple Watch, do iOS, das permissões HealthKit e da frequência com que o HealthKit disponibiliza amostras.
- HRV pode não estar disponível em tempo real ou em todas as sessões.
- O app não envia notificações automáticas.
- O app não usa IA, previsão ou diagnóstico.
- O ícone e a splash screen ainda usam assets básicos do projeto Flutter e devem receber branding final antes do lançamento público.

## Linguagem responsável

Use SignalFlow como ferramenta experimental de observação e organização de dados pessoais. Os dados exibidos podem ajudar a acompanhar tendências durante sessões, mas não devem ser interpretados como avaliação clínica.

Este app não substitui atendimento profissional. Em caso de emergência ou sofrimento intenso, procure ajuda profissional ou serviços de emergência locais.

## Instruções básicas de teste

1. Instale o build via TestFlight.
2. Abra SignalFlow e conclua o onboarding.
3. Em Configurações, teste a fonte Simulação.
4. Em Configurações, selecione HealthKit (experimental).
5. Toque em Solicitar permissão e permita frequência cardíaca e HRV, se solicitado.
6. Toque em Ler último dado e confirme se aparece uma leitura ou uma mensagem segura de ausência de dados.
7. Abra Modo pesquisa, inicie uma sessão e observe se amostras entram quando houver dados HealthKit.
8. Execute o diagnóstico bruto HealthKit para verificar timestamps e quantidade de samples.
9. Abra Protocolo guiado, inicie uma sessão e passe pelas fases disponíveis.
10. Exporte CSVs de sessão, diagnóstico, análise temporal e análise do protocolo quando houver dados.

