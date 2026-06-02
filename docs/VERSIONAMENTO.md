# Regra oficial de versionamento - Rodizio de Brinquedos

No Rodizio de Brinquedos, o campo `version:` do `pubspec.yaml` e a fonte principal de versionamento.

Exemplo:

```yaml
version: 1.0.4+79
```

Onde:
- `1.0.4` e a versao visivel para o usuario.
- `79` e o numero interno do build.

O numero interno do build deve seguir uma fila unica e crescente para Android e iOS.

## Regra obrigatoria

- Nunca repetir build number.
- Nunca diminuir build number.
- Sempre incrementar +1 antes de enviar uma nova build para qualquer loja.
- A fila e unica para iOS e Android.
- Nao existe fila separada para Android e iOS.
- Se Android usou `+79`, a proxima build, mesmo que seja iOS, deve ser `+80`.
- Se iOS usou `+80`, a proxima build, mesmo que seja Android, deve ser `+81`.

## Exemplos corretos

- `1.0.4+79` Android teste interno
- `1.0.4+80` Android correcao
- `1.0.4+81` iOS TestFlight
- `1.0.5+82` proxima versao publica maior

## Exemplos proibidos

- Reutilizar `1.0.4+79`
- Voltar para `1.0.4+78`
- Usar `1.0.4+80` no Android e depois tentar usar `1.0.4+80` no iOS
- Alterar versao diretamente no Gradle ou Xcode sem alinhar com `pubspec.yaml`

## Regra operacional antes de builds

Antes de qualquer build para Google Play ou App Store, sempre executar:

```sh
grep "^version:" pubspec.yaml
```

Depois confirmar:
- build number atual
- proximo build number livre
- loja de destino
- se ja existe build anterior enviado com aquele numero

## Android

- `versionName` vem de `1.0.4`
- `versionCode` vem de `+79`
- Google Play nao aceita versionCode repetido
- Sempre subir o `+build` antes de enviar novo AAB

## iOS

- Versao visivel pode ser igual a do Android.
- Build number tambem deve seguir a fila global.
- Nao voltar para builds antigos.
- Nao alterar versao manualmente no Xcode sem refletir no `pubspec.yaml`.

## Regra de simplicidade

A versao visivel so muda quando houver mudanca relevante para o usuario.
O build number muda em toda submissao.

Exemplos:
- Correcao pequena antes da publicacao: `1.0.4+79` -> `1.0.4+80`
- Nova versao com recurso relevante: `1.0.4+80` -> `1.0.5+81`

## Estado atual

- App: Rodizio de Brinquedos
- Flutter e a fonte principal do versionamento.
- Arquivo principal: `pubspec.yaml`
- Versao atual confirmada: `version: 1.0.4+79`
- Android usa:
  - `versionName = 1.0.4`
  - `versionCode = 79`
- iOS usa:
  - `CFBundleShortVersionString = 1.0.4`
  - `CFBundleVersion = 79`
  - ou equivalentes derivados do Flutter
- O Android ja usou o `versionCode 78` no Google Play Console.
- O build Android corrigido atual e `1.0.4+79`.
- iOS mantem paywall ativo.
- Android esta temporariamente sem paywall ate configurar Google Play Billing.

