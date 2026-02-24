# Rodízio de Brinquedos v3 — Project Archive

Este arquivo registra cada mudança proposta no chat, com snapshots versionados.
Regra geral do projeto:
- Toda mudança proposta pelo ChatGPT deve ser registrada aqui
- Sempre que um arquivo for alterado, o conteúdo completo é entregue para copiar/colar
- O histórico serve como “fonte de verdade” evolutiva do projeto

---

## SNAPSHOT v0.1 — Base mínima rodando
(sem mudanças)

## HOTFIX v0.1.1 — Ajuste de versões Drift
(sem mudanças)

## SNAPSHOT v0.2 — Banco de dados (Drift) mínimo
(sem mudanças)

## SNAPSHOT v0.3 — Banco ligado à UI (ToyRepository + Bootstrap)
(sem mudanças)

## SNAPSHOT v0.4 — Rounds (rodada ativa)
(sem mudanças)

---

## HOTFIX v0.4.2 — Corrigir tipos gerados e tipagem da UI
**Motivo**
- Drift não gera `ToysData/RoundsData` por padrão; gera `Toy/Round` (singular).
- A Home estava recebendo `Object` por falta de tipagem.
- Era necessário regenerar o `app_database.g.dart` após mudanças nas tabelas.

### Arquivos alterados
- lib/data/repositories/toy_repository.dart
- lib/data/repositories/round_repository.dart
- lib/ui/home_page.dart
- docs/PROJECT_ARCHIVE.md

### Mudanças
- Repositórios voltaram a usar tipos gerados padrão: `Toy` e `Round`
- `StreamBuilder` tipados: `StreamBuilder<Round?>` e `StreamBuilder<List<Toy>>`
- Instrução: sempre rodar build_runner após alterar schema/tabelas
