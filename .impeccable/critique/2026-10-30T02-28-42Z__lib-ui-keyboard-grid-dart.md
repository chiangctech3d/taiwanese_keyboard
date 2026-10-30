---
target: lib/ui/keyboard_grid.dart
total_score: 24
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 3
target_identity: "file:C:\\Users\\MacOS\\Documents\\GitHub\\taiwanese_keyboard\\lib\\ui\\keyboard_grid.dart"
target_fingerprint: "sha256:7b692d2ed8c7a168f437b1e3f98fe17288c31bb65450f05070b942857ffa0d33"
target_path: "C:\\Users\\MacOS\\Documents\\GitHub\\taiwanese_keyboard\\lib\\ui\\keyboard_grid.dart"
timestamp: 2026-10-30T02-28-42Z
slug: lib-ui-keyboard-grid-dart
---
Method: design review only (detector not applicable, native platform)

## Design Health Score
| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | Botão Shift não acende quando o Shift físico/Caps está ativo; nada confirma o caractere enviado |
| 2 | Match System / Real World | 3 | Ordem e números de tom seguem a convenção POJ; tecla ⁿ parece um "n" comum |
| 3 | User Control and Freedom | 3 | Shift liga/desliga com um clique; desfazer fica no app de destino |
| 4 | Consistency and Standards | 2 | Visual Material (ripple, cantos, cinza esverdeado) — não parece Windows nem Mac, contra o PRODUCT.md |
| 5 | Error Prevention | 3 | Teclas bem separadas; ⁿ/ᴺ confundíveis com n/N |
| 6 | Recognition Rather Than Recall | 3 | Tudo visível; trava do Shift por duplo clique não é descoberta |
| 7 | Flexibility and Efficiency | 2 | Integração com Shift físico é ótima; sem recentes/atalhos |
| 8 | Aesthetic and Minimalist Design | 2 | 7ª coluna quase vazia descentraliza a grade; glifos pequenos em teclas grandes; cabeçalho apagado |
| 9 | Error Recovery | 3 | Fallback copia e diz como colar; Mac oferece "Permitir" |
| 10 | Help and Documentation | 1 | Nenhuma dica no app; tooltip só mostra U+XXXX |
| **Total** | | **24/40** | **Acceptable** |

## Priority Issues
- [P1] Diacríticos pequenos para o tamanho da tecla (20px em teclas 48×38): acento vertical do tom 8 e o ponto do o͘ quase somem. Fix: glifo 26–28px, ajustar altura de linha; reduzir padding interno. Cmd: typeset
- [P1] Estado do Shift invisível quando vem do teclado físico: grade vira maiúscula mas botão continua apagado. Fix: botão reflete 3 estados (físico/único/travado). Cmd: polish
- [P1] Layout com 7ª coluna usada só pelo o͘ sem tom: grade descentralizada e janela 1/7 mais larga que o necessário (fere "janela mínima"). Fix: mover o͘ e ⁿ para a linha de baixo junto ao Shift, grade 6 colunas. Cmd: layout
- [P2] Visual Material em desktop: ripple e paleta esverdeada não são nativos. Fix: hover/press sutis, cores do sistema (accent do Windows / macOS), cantos 4–6px. Cmd: adapt / polish
- [P2] Tecla ⁿ ilegível e cabeçalho de tons com baixo contraste; "8 ̍" vira um risco. Fix: ⁿ com base visível (ex.: "◌ⁿ" ou "aⁿ" como rótulo), cabeçalho maior e com contraste AA. Cmd: typeset

## Persona Red Flags
- Alex (power user): sem atalhos; precisa mirar com o mouse em teclas de 48px; sem "recentes".
- Sam (acessibilidade): janela não ativável impede navegação por teclado (por design); cabeçalho em cor outline < 4.5:1; tom 8 quase invisível.
- Estudante (projeto): não sabe que a coluna "8" é o tom 8 só pelo risco; tooltip mostra U+030D em vez de "tom 8 (pe̍k)"; double-tap do Shift oculto.

## Minor Observations
- Sem feedback de envio além do ripple; um flash curto na tecla bastaria.
- Ícone de Caps lock só aparece no modo travado; modo único e físico iguais.
- Snackbar ocupa a base da janela pequena e cobre a linha do Shift por 3s.

## Questions to Consider
- E se o tamanho do glifo fosse o protagonista, com tecla quase sem moldura?
- A janela precisa mostrar as 8 linhas sempre, ou o estudante quer o número do tom e o power user não?
- Como seria parecer um painel do próprio sistema (Painel de emoji do Windows, Visualizador de Caracteres do Mac)?
