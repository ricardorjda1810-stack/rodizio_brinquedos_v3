## Regra oficial de versionamento - Rodizio de Brinquedos

No Rodizio de Brinquedos, o campo `version:` do `pubspec.yaml` e a fonte oficial de versionamento.

Exemplo de formato:
`version: X.Y.Z+N`

Onde:
- `X.Y.Z` e a versao visivel para o usuario.
- `N` e o numero interno do build.

A versao atual nunca deve ser inferida a partir deste arquivo. Antes de qualquer decisao de versao ou build, sempre obter a versao real com:

```sh
grep "^version:" pubspec.yaml
```

Em caso de divergencia entre `AGENTS.md`, `docs/VERSIONAMENTO.md` e `pubspec.yaml`, o `pubspec.yaml` vence.

O numero interno do build deve seguir uma fila unica e crescente para Android e iOS.

Regra obrigatoria:
- Nunca repetir build number.
- Nunca diminuir build number.
- Sempre incrementar +1 antes de enviar uma nova build para qualquer loja.
- A fila e unica para iOS e Android.
- Nao existe fila separada para Android e iOS.
- Se Android usou `+N`, a proxima build, mesmo que seja iOS, deve usar `+(N+1)`.
- Se iOS usou `+N`, a proxima build, mesmo que seja Android, deve usar `+(N+1)`.

Exemplos corretos:
- `1.2.0+100` Android teste interno
- `1.2.0+101` Android correcao
- `1.2.0+102` iOS TestFlight
- `1.2.1+103` proxima versao publica maior

Exemplos proibidos:
- Reutilizar um build number ja enviado.
- Voltar para build number menor.
- Usar o mesmo build number no Android e depois tentar usar o mesmo build number no iOS.
- Alterar versao diretamente no Gradle ou Xcode sem alinhar com `pubspec.yaml`.

Antes de qualquer build para Google Play ou App Store, sempre executar:

```sh
grep "^version:" pubspec.yaml
```

Depois confirmar:
- build number atual
- proximo build number livre
- loja de destino
- se ja existe build anterior enviado com aquele numero

Android:
- `versionName` vem da parte visivel de `version:`
- `versionCode` vem da parte apos `+`
- Google Play nao aceita `versionCode` repetido
- Sempre subir o `+build` antes de enviar novo AAB

iOS:
- versao visivel pode ser igual a do Android
- build number tambem deve seguir a fila global
- nao voltar para builds antigos
- nao alterar versao manualmente no Xcode sem refletir no `pubspec.yaml`

Regra de simplicidade:
- A versao visivel so muda quando houver mudanca relevante para o usuario.
- O build number muda em toda submissao.

Exemplos:
- Correcao pequena antes da publicacao: `1.2.0+100` -> `1.2.0+101`
- Nova versao com recurso relevante: `1.2.0+101` -> `1.2.1+102`

## Validacoes antes de commit ou entrega

Depois de alterar codigo Dart/Flutter, sempre rodar:

```sh
flutter analyze
```

Se existir pasta `test/`, rodar tambem:

```sh
flutter test
```

## Paywall e compras

- Planejamento Semanal e recurso Premium.
- O app gratuito mantem cadastro, categorias, caixas, locais, rodizio diario e sugestao de rodada liberados.
- A regra de bloqueio deve ser coerente com `paywall_platform.dart`.
- Nao alterar comportamento de paywall, compras, assinatura, Product IDs ou disponibilidade por plataforma sem confirmacao explicita da loja de destino.
- Se Android estiver temporariamente sem compra ativa na loja, tratar como decisao operacional explicita e documentada, nao como regra padrao do produto.
- Nao alterar Gradle, Xcode, AndroidManifest, Info.plist ou `pubspec.yaml` para builds ou paywall sem instrucao explicita.
