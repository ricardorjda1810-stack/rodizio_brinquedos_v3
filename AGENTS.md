# Instruções para agentes — Rodízio de Brinquedos

## Escopo do projeto

- O aplicativo Flutter principal está na raiz deste repositório: `pubspec.yaml`, `lib/`, `test/`, `android/` e `ios/`.
- `alerta_de_crise/` é um projeto Flutter aninhado e separado. Não o modifique, valide, versione ou inclua em uma tarefa do app principal sem solicitação explícita.
- Preserve o escopo mínimo: não altere arquivos não relacionados à tarefa.

## Git e segurança operacional

- GitHub é a fonte oficial do código e do histórico. Trabalhe em uma branch ou worktree isolada por tarefa; nunca trabalhe diretamente na `main`.
- Antes de agir localmente, inspecione o estado Git. Nunca formate, mova, descarte, faça commit ou misture alterações locais preexistentes que não pertençam à tarefa.
- Não execute `reset`, `clean`, `stash`, rebase, force push ou operações destrutivas sem autorização explícita.
- Não faça merge, publicação, upload para TestFlight, App Store, Google Play, Codemagic, Xcode Cloud ou outra ação externa/irreversível sem autorização humana explícita.
- Antes de concluir, revise o diff completo e não invente resultados de testes, builds ou validações.

## Regra oficial de versionamento

No Rodízio de Brinquedos, o campo `version:` do `pubspec.yaml` é a fonte oficial de versionamento.

Formato: `version: X.Y.Z+N`

- `X.Y.Z` é a versão visível para a pessoa usuária.
- `N` é o número interno do build.
- Nunca infira a versão atual deste arquivo. Antes de decidir versão ou build, execute `grep "^version:" pubspec.yaml`.
- Em caso de divergência entre este arquivo, `docs/VERSIONAMENTO.md` e `pubspec.yaml`, `pubspec.yaml` prevalece.
- O número de build é uma fila única e crescente para Android e iOS: nunca o repita ou diminua; incremente-o antes de enviar uma nova build para qualquer loja.
- Não altere versão diretamente no Gradle ou Xcode sem refletir em `pubspec.yaml`.

Antes de qualquer build para Google Play ou App Store, confirme a versão atual, o próximo build livre, a loja de destino e se o número já foi enviado.

## Validações

- Após alterar código Dart/Flutter do app principal, execute `flutter analyze --no-pub lib test` e, se `test/` existir, `flutter test`.
- Para alterações Android, consulte a documentação oficial do Android antes de alterar APIs, Gradle ou Google Play Billing.
- Validações dependentes de Xcode, CocoaPods, Simulator, Keychain, assinatura ou credenciais locais devem ser executadas e relatadas no Mac; não presuma seus resultados remotamente.

## Paywall, compras e ambientes

- Planejamento Semanal é recurso Premium; cadastro, categorias, caixas, locais, rodízio diário e sugestão de rodada permanecem disponíveis no app gratuito.
- Mantenha a coerência com `paywall_platform.dart`. Não altere paywall, compras, assinatura, Product IDs ou disponibilidade por plataforma sem confirmação explícita da loja de destino.
- Preserve StoreKit 2, os ambientes staging/produção e a instrumentação analítica existente, salvo solicitação explícita e escopo confirmado.
- Não altere Gradle, Xcode, AndroidManifest, Info.plist ou `pubspec.yaml` para builds ou paywall sem instrução explícita.

## Entrega obrigatória

Ao final de cada tarefa, informe: SHA-base, SHA final, branch, arquivos alterados, validações executadas e seus resultados, itens não validados, pendências, riscos e autorizações ainda necessárias.
