# Teclado Taiwanês — Design

Data: 2026-10-29

## Objetivo

App de desktop (Windows e macOS) com um teclado virtual flutuante para os
caracteres especiais do taiwanês (POJ). Ao clicar num caractere, ele é
**digitado diretamente** no aplicativo que estava em uso (Word, navegador,
etc.), funcionando em conjunto com o teclado físico.

Sucesso = o usuário escreve POJ em qualquer app, alternando entre teclado
físico e cliques no teclado virtual, sem perder o cursor; executáveis para
Windows e Mac gerados automaticamente pelo GitHub.

## Stack

- Flutter (Dart) desktop, desenvolvido no VS Code.
- Windows: pacote `win32` (FFI) para chamadas nativas.
- macOS: pequeno código Swift via platform channel.
- Repositório GitHub: `teclado-taiwanes`.

## Caracteres

Tons em colunas (ordem da tabela original): 2 ´, 3 `, 5 ^, 7 ¯, 8 ̍ (U+030D), 9 ˘.

| Base | 2 | 3 | 5 | 7 | 8 | 9 |
|------|---|---|---|---|---|---|
| a | á | à | â | ā | a̍ | ă |
| e | é | è | ê | ē | e̍ | ĕ |
| i | í | ì | î | ī | i̍ | ĭ |
| o | ó | ò | ô | ō | o̍ | ŏ |
| o͘ | ó͘ | ò͘ | ô͘ | ō͘ | o̍͘ | ŏ͘ |
| u | ú | ù | û | ū | u̍ | ŭ |
| m | ḿ | m̀ | m̂ | m̄ | m̍ | m̆ |
| n | ń | ǹ | n̂ | n̄ | n̍ | n̆ |

Extras: `o͘` sem tom (célula extra na linha o͘) e `ⁿ` (maiúscula: `ᴺ`).
Cada caractere tem forma maiúscula correspondente (ver tabela original do usuário).
Caracteres podem ser sequências com diacríticos combinantes; são tratados
sempre como `String`, nunca como um único code point.

## Interface

- Janela pequena, sempre no topo, **não rouba foco**, arrastável.
- Grade 8 linhas × 6 tons + célula extra do o͘ sem tom + botão ⁿ/ᴺ.
- Cabeçalho das colunas mostra número e marca do tom.
- Botão **Shift** virtual: um clique = maiúscula para o próximo caractere
  (volta sozinho); duplo clique = trava (como Caps Lock).
- Tooltip mostra o(s) código(s) Unicode do caractere.

## Integração com o teclado físico

- O app consulta o estado global do teclado a cada ~30 ms:
  - Windows: `GetAsyncKeyState(VK_SHIFT)` e `GetKeyState(VK_CAPITAL)`.
  - macOS: `NSEvent.modifierFlags` (sem permissão extra).
- Grade exibe maiúsculas se: Shift físico pressionado **ou** Caps Lock físico
  ativo **ou** Shift virtual ativo/travado.
- Ao enviar o caractere, nenhum modificador é aplicado ao evento, para o
  Shift físico não interferir no app de destino.

## Arquitetura

```
lib/
  main.dart
  data/poj_chars.dart          # tabela de caracteres (só dados)
  ui/keyboard_grid.dart        # grade + Shift
  ui/app.dart                  # janela/tema
  typing/typer.dart            # interface: Future<bool> type(String)
  typing/windows_typer.dart    # SendInput + KEYEVENTF_UNICODE por unidade UTF-16
  typing/macos_typer.dart      # channel -> Swift CGEventKeyboardSetUnicodeString
  keyboard_state/keyboard_state.dart   # interface: bool isShiftDown(), bool isCapsOn()
  keyboard_state/windows_keyboard_state.dart
  keyboard_state/macos_keyboard_state.dart
  window/window_setup.dart     # interface: configurar janela flutuante sem foco
  window/windows_window.dart   # WS_EX_NOACTIVATE + topmost
  window/macos_window.dart     # NSPanel nonactivating (Swift)
macos/Runner/                  # Swift: typer, estado de teclado, painel, permissão
```

Cada unidade depende só da interface da outra; implementações escolhidas
por plataforma em `main.dart`.

## Erros e casos-limite

- macOS sem permissão de Acessibilidade: copia para área de transferência,
  mostra aviso "Cole com ⌘V" e botão que abre Ajustes > Privacidade >
  Acessibilidade.
- Falha de digitação em qualquer SO (`type` retorna false): copia para a
  área de transferência e mostra aviso.

## Testes

- Unitários: tabela completa (contagem bate com a lista original; todo
  minúsculo tem maiúsculo; strings em NFC/sequência esperada).
- Widget: grade alterna maiúsculas com Shift virtual (único e travado) e com
  `KeyboardState` falso simulando Shift/Caps físicos.
- Manual (checklist no README): Notepad, Word, navegador, TextEdit; Shift
  físico; Mac sem e com permissão.

## Entrega (GitHub Actions)

- Workflow em `.github/workflows/release.yml`, disparado por tag `v*`:
  - job `windows-latest`: `flutter build windows` → zip do `Release/`.
  - job `macos-latest`: `flutter build macos` → `.dmg`.
  - Publica ambos num GitHub Release.
- Workflow de CI (`ci.yml`) em push/PR: `flutter analyze` + `flutter test`.
- App macOS não assinado; README explica abrir com clique direito → Abrir.

## Fora de escopo

- Método de entrada do sistema (IME), assinatura/notarização Apple,
  instalador Windows (.msi), Linux.
