# Instruções para GitHub Copilot

Leia e siga primeiro o `AGENTS.md`, que é a fonte principal das regras do repositório.

- Confirme qual projeto está no escopo. Para tarefas do app principal, use a raiz (`pubspec.yaml`, `lib/`, `test/`, `android/`, `ios/`) e não altere `alerta_de_crise/` sem solicitação explícita.
- Faça somente a menor mudança relacionada à tarefa; não inclua refatorações, formatação ampla ou arquivos não relacionados.
- Antes de editar localmente, preserve alterações preexistentes. Não as mova, descarte, formate, inclua em commits ou misture com a tarefa.
- Diferencie claramente fatos confirmados, hipóteses e itens não verificados. Nunca invente resultados de análise, testes, builds ou validações locais.
- Use os comandos definidos no `AGENTS.md` para o escopo alterado e revise o diff completo antes de concluir.
- Não exija reproduzir todos os arquivos completos na resposta; apresente somente o contexto e os trechos necessários.
- Trabalhe em branch ou worktree isolada. Não faça commit direto na `main`, merge, publicação, upload, alteração de serviços externos ou outra ação irreversível sem autorização humana explícita.
