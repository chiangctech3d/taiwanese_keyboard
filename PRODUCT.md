# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

Desktop: Windows e macOS (Flutter). "Adaptive" aqui significa seguir a
linguagem visual nativa de cada sistema desktop (Windows 11 / macOS), não
iOS/Android.

## Users

- O próprio autor, escrevendo Pe̍h-ōe-jī (POJ) no dia a dia: mensagens,
  documentos, trabalho de dicionário.
- Estudantes de taiwanês, ainda memorizando as marcas de tom.
- Escritores, editores e tradutores que escrevem muito em POJ e querem
  velocidade.
- A comunidade de falantes em geral (distribuição pública e gratuita no
  GitHub).

Situação comum a todos: estão escrevendo em outro programa (Word,
navegador, chat) e precisam inserir um caractere com diacrítico que o
teclado físico não oferece.

## Product Purpose

Teclado virtual flutuante com os caracteres especiais do POJ (vogais com
tons 2, 3, 5, 7, 8, 9; o͘; m e n com diacríticos; ⁿ). Um clique digita o
caractere direto no programa em uso, sem tirar o foco dele, e o teclado
funciona junto com o teclado físico (o Shift físico muda a grade para
maiúsculas).

Sucesso = escrever POJ em qualquer programa alternando teclado físico e
cliques, sem perder o cursor e sem precisar copiar/colar.

## Positioning

Digita direto no app ativo (não é uma página de copiar/colar nem um IME
que exige configuração do sistema) e reage ao Shift/Caps Lock físico.
Cobre as sequências combinantes do POJ (a̍, o̍͘, m̄…) que não existem como
caractere único.

## Operating Context

- Janela pequena, sempre por cima, ao lado do documento; não rouba o foco.
- Uso alternado: mão no teclado físico, mouse no teclado virtual.
- Windows: digitação via SendInput. macOS: via CGEvent, requer permissão de
  Acessibilidade; sem ela, o caractere é copiado e o usuário cola com ⌘V.
- Distribuído como .zip (Windows) e .dmg não assinado (macOS) via GitHub
  Releases.

## Capabilities and Constraints

- Duas linhas, como tecla morta de teclado normal: acentos (tons 2, 3, 5,
  7, 8, 9) em cima; letras a, e, i, o, o͘, u, m, n e ⁿ embaixo. Acento +
  letra = combinação; letra sozinha = letra simples; ⁿ não recebe acento.
  Maiúsculas só pelo Shift/Caps Lock físico (sem Shift na tela).
- Caracteres são strings, às vezes com diacríticos combinantes; a fonte
  precisa renderizar U+030D e U+0358 corretamente.
- Tooltip com o código Unicode de cada tecla.
- Restrição em tensão, ambas confirmadas pelo usuário: **teclas e letras
  grandes** (legibilidade dos diacríticos é prioridade) **e janela mínima**
  (ocupar o menor espaço possível na tela).
- Interface em português (Brasil); termos POJ em POJ.

## Brand Commitments

- Nome: "Teclado Taiwanês". Repositório: `chiangctech3d/taiwanese_keyboard`.
- Seguir o visual nativo de cada sistema (Windows e macOS), não uma
  identidade própria única.

## Evidence on Hand

- Tabela de caracteres fornecida pelo usuário (`lib/data/poj_chars.dart`).
- Não há logotipo, ícone próprio, depoimentos nem usuários registrados;
  não inventar.

## Product Principles

1. O foco é do documento do usuário: o teclado nunca o rouba.
2. O diacrítico precisa ser legível de relance; tamanho vence decoração.
3. Ocupar pouco espaço: cada pixel da janela precisa se justificar.
4. Parecer parte do sistema operacional, não um app estranho.
5. Funcionar igual com mouse ou com teclado físico combinado.

## Accessibility & Inclusion

Legibilidade de diacríticos pequenos (acento vertical U+030D, ponto
U+0358) é requisito; usuários incluem estudantes que precisam distinguir
tons visualmente.
