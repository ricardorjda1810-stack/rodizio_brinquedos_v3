# Regra oficial de versionamento — Rodízio de Brinquedos

O campo `version:` do `pubspec.yaml` é a fonte oficial de versionamento.

Exemplo:

```yaml
version: 1.0.4+79
```

Onde:

- `1.0.4` é a versão visível para a pessoa usuária.
- `79` é o número interno do build.

> Não mantenha uma versão atual manualmente neste documento. Antes de tomar qualquer decisão de versão ou build, consulte o valor efetivo com `grep "^version:" pubspec.yaml`.

O número interno do build deve seguir uma fila única e crescente para Android e iOS.

## Regra obrigatória

- Nunca repetir build number.
- Nunca diminuir build number.
- Sempre incrementar `+1` antes de enviar uma nova build para qualquer loja.
- A fila é única para iOS e Android.
- Não existe fila separada para Android e iOS.
- Se Android usou `+79`, a próxima build, mesmo que seja iOS, deve ser `+80`.
- Se iOS usou `+80`, a próxima build, mesmo que seja Android, deve ser `+81`.

## Exemplos corretos

- `1.0.4+79`: teste interno Android.
- `1.0.4+80`: correção Android.
- `1.0.4+81`: TestFlight iOS.
- `1.0.5+82`: próxima versão pública maior.

## Exemplos proibidos

- Reutilizar `1.0.4+79`.
- Voltar para `1.0.4+78`.
- Usar `1.0.4+80` no Android e depois tentar usar `1.0.4+80` no iOS.
- Alterar versão diretamente no Gradle ou Xcode sem alinhar com `pubspec.yaml`.

## Regra operacional antes de builds

Antes de qualquer build para Google Play ou App Store, execute:

```sh
grep "^version:" pubspec.yaml
```

Depois confirme:

- build number atual;
- próximo build number livre;
- loja de destino;
- se já existe build anterior enviado com aquele número.

## Android

- `versionName` vem da parte visível da versão.
- `versionCode` vem da parte após `+`.
- Google Play não aceita `versionCode` repetido.
- Sempre suba o `+build` antes de enviar novo AAB.

## iOS

- A versão visível pode ser igual à do Android.
- O build number também segue a fila global.
- Não retorne para builds antigos.
- Não altere versão manualmente no Xcode sem refletir no `pubspec.yaml`.

## Regra de simplicidade

A versão visível só muda quando houver mudança relevante para a pessoa usuária. O build number muda em toda submissão.
