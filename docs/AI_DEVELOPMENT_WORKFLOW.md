# Fluxo de desenvolvimento com GitHub, Copilot, Codex e Mac

## Fonte oficial e responsabilidade das ferramentas

O GitHub é a fonte oficial do código, histórico, branches, pull requests (PRs), checks e revisão. Toda mudança deve ser rastreável por branch, SHA e diff.

- **GitHub Copilot:** assistência de código e revisão contextual no repositório. Deve seguir `AGENTS.md` e manter o escopo mínimo.
- **Codex remoto:** tarefas que podem ser feitas em ambiente remoto e isolado, sem depender do estado local do Mac, Xcode, Keychain ou credenciais locais.
- **Codex local/desktop no Mac:** inspeção local e validações que dependem do macOS ou de ferramentas/credenciais locais.
- **Mac:** obrigatório quando a validação exigir Xcode, CocoaPods, iOS Simulator, Keychain, signing, perfis de provisionamento ou outra credencial/configuração local.

## Isolamento e sincronização

Use **uma tarefa por branch ou worktree**. Comece por uma `origin/main` atualizada e registre o SHA-base:

```sh
git fetch origin --prune
git switch --create <tipo>/<tarefa> --track origin/main
git rev-parse HEAD
```

Para trabalho paralelo local, prefira um worktree separado:

```sh
git worktree add ../rodizio-<tarefa> -b <tipo>/<tarefa> origin/main
```

Antes de continuar localmente uma branch iniciada remotamente, verifique o estado do Git no Mac (`git status --short --branch`, `git remote -v`, `git rev-parse HEAD` e `git worktree list`). Alterações locais preexistentes devem permanecer intactas. Essa verificação local não bloqueia tarefas remotas em branches isoladas.

Não permita que dois agentes alterem simultaneamente os mesmos arquivos. Divida o trabalho por arquivos/escopo ou aguarde o PR/branch em andamento antes de iniciar a segunda tarefa.

## Fluxo recomendado

1. Definir escopo, arquivos esperados e validações.
2. Criar branch ou worktree isolado a partir de `origin/main` atualizado.
3. Implementar a menor mudança necessária.
4. Executar validações aplicáveis ao escopo e ao ambiente disponível.
5. Revisar o diff, incluindo nomes de arquivos e alterações inesperadas.
6. Somente após obter as autorizações específicas e separadas correspondentes, criar o commit, fazer push da branch e criar o PR em **draft** contra `main`, com SHA-base, SHA final, testes e pendências.
7. Revisar código, checks e riscos. Marcar o PR como pronto e fazer merge são ações distintas e cada uma exige sua própria autorização humana explícita.

## Transferência entre ferramentas

Ao transferir uma tarefa entre GitHub, Codex remoto, Codex local e Mac, informe sempre:

- SHA-base e SHA final, se houver;
- branch ou worktree;
- arquivos alterados e resumo do diff;
- validações executadas e resultados;
- itens não validados e motivo;
- pendências, riscos e a próxima ação autorizada.

Não trate uma validação remota como substituta de uma validação dependente do Mac. Da mesma forma, não copie alterações locais para outra tarefa sem revisar o diff e confirmar a base Git.

## Ações que exigem autorização humana

Cada uma destas ações exige autorização humana específica e separada: criar commit; fazer qualquer push; criar ou alterar PR; marcar PR como pronto; fazer merge ou habilitar auto-merge; publicar ou alterar serviço externo. Isso inclui TestFlight, App Store, Google Play, Codemagic, Xcode Cloud, assinatura, certificados, segredos, Keychain, proteção de branch e mudanças de versão/build ou dependências.

Force push, rebase, reset e limpeza destrutiva também exigem autorização explícita. Atualizar arquivos localmente ou executar validações não autoriza automaticamente nenhuma das ações acima.

## Modelo de relatório de entrega

```text
SHA-base:
SHA final:
Branch:
Arquivos alterados:
Validações executadas:
Resultados:
Itens não validados:
Riscos e pendências:
Ação externa realizada:
Autorização ainda necessária:
```
