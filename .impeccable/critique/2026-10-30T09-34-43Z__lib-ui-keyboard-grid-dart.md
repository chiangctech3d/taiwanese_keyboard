---
target: lib/ui/keyboard_grid.dart
total_score: 27
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 2
target_identity: "file:C:\\Users\\MacOS\\Documents\\GitHub\\taiwanese_keyboard\\lib\\ui\\keyboard_grid.dart"
target_fingerprint: "sha256:9ef7577041c5a7898c9f5f9881748515de5e834e7a810e4b5021123a2560e7d8"
target_path: "C:\\Users\\MacOS\\Documents\\GitHub\\taiwanese_keyboard\\lib\\ui\\keyboard_grid.dart"
timestamp: 2026-10-30T09-34-43Z
slug: lib-ui-keyboard-grid-dart
---
Method: design review only (detector not applicable, native platform)

## Design Health Score
| # | Heurística | Nota | Problema principal |
|---|---|---|---|
| 1 | Visibilidade do estado | 3 | Acento armado em primary; letras mostram a prévia. Falta sinal de envio; "Verificando…" não se distingue |
| 2 | Mundo real | 3 | Tecla morta como teclado comum; ^ a 40px parecia Λ (corrigido) |
| 3 | Controle | 3 | Acento desarma com clique ou após letra; não expira |
| 4 | Consistência | 2 | Marcas de tom com tamanhos desiguais (corrigido); ⁿ apagado clicável (corrigido); A−/A+ desativado com hover (corrigido); seed verde não é accent do sistema |
| 5 | Prevenção | 3 | ⁿ com acento descartava o tom sem aviso (corrigido: desativado) |
| 6 | Reconhecer | 3 | Prévia nas letras; tooltip só U+ (corrigido: "â · tom 5 · U+00E2") |
| 7 | Eficiência | 2 | Sem trava de acento, recentes ou atalhos |
| 8 | Minimalismo | 3 | Rodapé 22/130px para uso raro; "Você está na última versão" fica para sempre |
| 9 | Recuperação | 3 | Fallback ok; "Não foi possível verificar" não convida a tentar de novo |
| 10 | Ajuda | 2 | Só tooltips de 600ms; sem dica de primeiro uso |
| **Total** | | **27/40** | **Acceptable** (antes 24/40) |

## Priority Issues
- [P1] Marcas de tom sem consistência óptica (^ 40px, ˈ minúsculo) — RESOLVIDO: tamanho/dy por marca (_markStyle)
- [P1] Tom 8 ilegível como rótulo — RESOLVIDO em parte: marca maior; número continua 10px
- [P2] Rodapé consome 17% da altura; "última versão" permanente — ABERTO (decisão do usuário)
- [P2] ⁿ "desabilitado" funciona; A−/A+ desabilitado com hover — RESOLVIDO: onTap nulo
- [P3] Paleta Material em vez do accent do sistema — ABERTO (decisão do usuário)

## Persona Red Flags
- Alex: 2 cliques por vogal tonal; sem trava de acento; acento armado não expira.
- Sam: sem teclado (por design); selected só por cor, sem Semantics; números 10px a 80% viram 8px.
- Estudante: tooltip agora diz o tom; sem prévia por hover; sem dica de primeiro uso.

## Minor
- toneHeaders só serve ao número; gap 2px fica 3px a 80%; SnackBar cobre as letras por 3s; "Verificando…" sem indicador.

## Questions
- Acentos desenhados (vetor) em vez de glifos? Rodapé só quando houver algo a dizer? Trava de acento por duplo clique? Hover no acento mostra prévia sem armar? Janela tingida pelo accent do sistema?
