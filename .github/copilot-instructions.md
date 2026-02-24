# Rodízio de Brinquedos 2.1 — Instruções para Agentes (FIVC)

## Princípios
- Simplicidade acima de tudo.
- Mudanças previsíveis e auditáveis.
- Evitar inconsistência entre arquivos (ex: UiTokens.*).

## Regra de Entrega (obrigatória)
Sempre entregar mudanças como:
1) Lista de arquivos alterados
2) Cada arquivo completo (pronto para copiar/colar)
3) Checklist "Find in project" com símbolos-chave para validar compatibilidade

## Estrutura
- lib/data: db + repositories
- lib/features: módulos (boxes, round, toys)
- lib/ui: tema + widgets

## Proibições
- Não criar regras paralelas fora do Chat 0.0.
- Não introduzir novos tokens/constantes sem entregar o arquivo completo do contrato (ex: ui_tokens.dart completo).
- Evitar mudanças espalhadas sem necessidade.
