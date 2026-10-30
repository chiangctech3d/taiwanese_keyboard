# Teclado Taiwanês Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** App Flutter desktop (Windows/macOS) com teclado virtual flutuante POJ que digita no app ativo e reage ao Shift físico.

**Architecture:** Dados puros (`poj_chars.dart`) → UI (`keyboard_grid.dart`) que depende de duas interfaces (`Typer`, `KeyboardState`) com implementações por SO; janela flutuante sem foco por SO. Fallback para área de transferência.

**Tech Stack:** Flutter stable, Dart, pacote `win32` + `ffi`, Swift (macOS), GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-10-29-teclado-taiwanes-design.md`

## Global Constraints

- Plataformas: Windows e macOS apenas (`flutter create --platforms=windows,macos`).
- Caracteres são `String` (podem ter diacríticos combinantes); nunca indexar por code point único.
- Ordem das colunas de tom: 2 ´, 3 `, 5 ^, 7 ¯, 8 ̍, 9 ˘.
- Polling do teclado físico: 30 ms.
- Envio de caractere sem modificadores aplicados.
- Nome do pacote Dart: `teclado_taiwanes`; repositório `teclado-taiwanes`.

## Review Focus

- Clique enquanto Shift físico está pressionado → deve sair maiúscula sem o app destino receber Shift (Task 3/4, teste manual + teste de widget com fake).
- Shift virtual único volta a minúsculas após um clique, mesmo se Caps físico ligado depois (Task 2 teste `shift único reseta`).
- Caracteres combinantes (o̍͘) enviados inteiros, não cortados (Task 3: teste de `toUtf16Units('o̍͘').length == 3`).
- Mac sem permissão → caractere copiado e aviso exibido (Task 5 teste com fake `Typer` retornando false).
- Janela não rouba foco ao clicar (teste manual no checklist do README).

---

### Task 1: Scaffold + tabela de caracteres + CI

**Files:**
- Create: projeto via `flutter create --platforms=windows,macos --project-name teclado_taiwanes .`
- Create: `lib/data/poj_chars.dart`
- Test: `test/poj_chars_test.dart`
- Create: `.github/workflows/ci.yml`, `.gitignore` (do flutter create)

**Interfaces:**
- Produces:
  - `class PojKey { final String lower; final String upper; }`
  - `const List<String> toneHeaders` = `['2 ´','3 `','5 ^','7 ¯','8 ̍','9 ˘']`
  - `const List<List<PojKey>> pojRows` — 8 linhas (a,e,i,o,o͘,u,m,n) × 6 tons
  - `const PojKey ohNoTone = PojKey('o͘','O͘')`, `const PojKey nasal = PojKey('ⁿ','ᴺ')`

- [ ] **Step 1: Teste**
```dart
test('8 linhas x 6 tons', () { expect(pojRows.length, 8); for (final r in pojRows) expect(r.length, 6); });
test('valores exatos', () {
  expect(pojRows[0][0].lower, 'á'); expect(pojRows[0][4].lower, 'a̍');
  expect(pojRows[4][4].lower, 'o̍͘'); expect(pojRows[4][4].upper, 'O̍͘');
  expect(pojRows[7][1].upper, 'Ǹ'); expect(nasal.upper, 'ᴺ');
});
test('maiúscula de toda tecla é diferente da minúscula', () { for (final r in pojRows) for (final k in r) expect(k.upper != k.lower, true); });
```
- [ ] **Step 2:** `flutter test test/poj_chars_test.dart` → FAIL (arquivo não existe)
- [ ] **Step 3:** Preencher `poj_chars.dart` copiando exatamente a tabela da spec (o͘ = `o͘`).
- [ ] **Step 4:** `flutter test` → PASS
- [ ] **Step 5:** `ci.yml`: em push/PR, `ubuntu-latest`, `subosito/flutter-action@v2` (channel stable), `flutter pub get`, `flutter analyze`, `flutter test`.
- [ ] **Step 6:** Commit `feat: scaffold e tabela POJ`

### Task 2: Interfaces + grade + Shift

**Files:**
- Create: `lib/typing/typer.dart`, `lib/keyboard_state/keyboard_state.dart`, `lib/ui/keyboard_grid.dart`, `lib/ui/app.dart`
- Test: `test/keyboard_grid_test.dart`

**Interfaces:**
- Produces:
  - `abstract class Typer { Future<bool> type(String text); }`
  - `abstract class KeyboardState { bool isShiftDown(); bool isCapsOn(); }`
  - `class KeyboardGrid extends StatefulWidget { KeyboardGrid({required Typer typer, required KeyboardState keyboardState, required void Function(String text) onFallback, Duration pollInterval = const Duration(milliseconds: 30)}) }`
  - Botão Shift com `Key('shift')`; tecla com `Key('k-<linha>-<col>')`, `Key('oh')`, `Key('nasal')`.
  - Regra: maiúscula = shiftFísico || capsFísico || shiftVirtual(único|travado). Toque simples = único (reseta após um envio); duplo toque = travado (alterna).
  - Se `typer.type` retorna false → chama `onFallback(text)`.

- [ ] **Step 1: Testes** (com `FakeTyper` gravando textos e `FakeKeyboardState` com campos mutáveis)
```dart
testWidgets('minúscula por padrão', ... tap k-0-0 → typed == ['á']);
testWidgets('shift único reseta', ... tap shift, tap k-0-0, tap k-0-0 → ['Á','á']);
testWidgets('shift travado', ... doubleTap shift, tap k-0-0 ×2 → ['Á','Á']);
testWidgets('shift físico', ... fake.shift=true; pump(40ms); tap k-0-0 → ['Á']; find.text('Á') findsOneWidget);
testWidgets('caps físico', ... fake.caps=true; pump(40ms); tap nasal → ['ᴺ']);
testWidgets('fallback', ... FakeTyper(result:false); tap k-0-0 → fallback == ['á']);
```
- [ ] **Step 2:** `flutter test test/keyboard_grid_test.dart` → FAIL
- [ ] **Step 3:** Implementar; `Timer.periodic(pollInterval)` faz `setState` só quando o estado muda; tooltip com `U+XXXX` de cada rune.
- [ ] **Step 4:** `flutter test` → PASS
- [ ] **Step 5:** Commit `feat: grade com shift virtual e físico`

### Task 3: Implementações Windows

**Files:**
- Create: `lib/typing/windows_typer.dart`, `lib/keyboard_state/windows_keyboard_state.dart`, `lib/window/window_setup.dart`, `lib/window/windows_window.dart`
- Modify: `pubspec.yaml` (deps `win32`, `ffi`)
- Test: `test/windows_typer_test.dart`

**Interfaces:**
- Consumes: `Typer`, `KeyboardState` (Task 2)
- Produces:
  - `List<int> toUtf16Units(String s)` (top-level, testável)
  - `class WindowsTyper implements Typer` — para cada unidade: INPUT keydown+keyup com `KEYEVENTF_UNICODE`, `wVk=0`, `wScan=unidade`; retorna `SendInput(...) == count`.
  - `class WindowsKeyboardState implements KeyboardState` — `GetAsyncKeyState(VK_SHIFT) & 0x8000 != 0`, `GetKeyState(VK_CAPITAL) & 1 != 0`.
  - `abstract class WindowSetup { Future<void> apply(); }`; `WindowsWindow` — `FindWindow('FLUTTER_RUNNER_WIN32_WINDOW', null)`, adiciona `WS_EX_NOACTIVATE | WS_EX_TOPMOST | WS_EX_TOOLWINDOW` via `SetWindowLongPtr(GWL_EXSTYLE)`, `SetWindowPos(HWND_TOPMOST, ..., SWP_NOMOVE|SWP_NOSIZE)`, tamanho inicial 460×360.

- [ ] **Step 1: Teste** `expect(toUtf16Units('o̍͘').length, 3); expect(toUtf16Units('á'), [0xE1]);`
- [ ] **Step 2:** `flutter test test/windows_typer_test.dart` → FAIL
- [ ] **Step 3:** Implementar os três arquivos.
- [ ] **Step 4:** `flutter test` → PASS; `flutter build windows` → sucesso.
- [ ] **Step 5:** Manual: `flutter run -d windows`, focar Notepad, clicar teclas; cursor permanece no Notepad; Shift físico segurado + clique → maiúscula.
- [ ] **Step 6:** Commit `feat: digitação e janela no Windows`

### Task 4: Implementações macOS

**Files:**
- Create: `macos/Runner/PojPlugin.swift`; Modify: `macos/Runner/MainFlutterWindow.swift`, `macos/Runner/*.entitlements` (`com.apple.security.app-sandbox` = false)
- Create: `lib/typing/macos_typer.dart`, `lib/keyboard_state/macos_keyboard_state.dart`, `lib/window/macos_window.dart`

**Interfaces:**
- Consumes: `Typer`, `KeyboardState`, `WindowSetup`
- Produces: `MethodChannel('teclado_taiwanes/native')` com métodos:
  - `type(String) -> bool` — se `!AXIsProcessTrusted()` retorna false; senão `CGEvent(keyboardEventSource:nil, virtualKey:0, keyDown:true/false)`, `flags = []`, `keyboardSetUnicodeString`, post `.cghidEventTap`.
  - `modifiers() -> {shift: bool, caps: bool}` — `NSEvent.modifierFlags`.
  - `requestAccessibility()` — `AXIsProcessTrustedWithOptions(prompt:true)`.
  - `openAccessibilitySettings()` — abre `x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility`.
  - `MainFlutterWindow`: `level = .floating`, `styleMask.insert(.nonactivatingPanel)` usando `NSPanel` como classe da janela, `becomesKeyOnlyIfNeeded = true`.
  - `MacosKeyboardState` guarda último valor e atualiza de forma assíncrona (a interface é síncrona): o próprio estado faz polling 30 ms.

- [ ] **Step 1:** Implementar Swift + Dart.
- [ ] **Step 2:** `flutter analyze` → sem erros; build mac verificado no CI (Task 6) pois não há Mac local.
- [ ] **Step 3:** Commit `feat: digitação e painel no macOS`

### Task 5: Integração + fallback

**Files:**
- Modify: `lib/main.dart`, `lib/ui/app.dart`; Create: `lib/typing/clipboard_fallback.dart`
- Test: `test/app_test.dart`

**Interfaces:**
- Produces: `Future<void> copyFallback(String text)` → `Clipboard.setData`; `App` mostra SnackBar `"Copiado — cole com Ctrl+V"` (Windows) / `"Copiado — cole com ⌘V"` + ação `"Permitir"` que chama `openAccessibilitySettings` (macOS).
- `main.dart`: escolhe implementações por `Platform.isWindows/isMacOS`, chama `WindowSetup.apply()`.

- [ ] **Step 1: Teste** `testWidgets('fallback mostra aviso', ... FakeTyper(false); tap k-0-0; pump; expect(find.textContaining('Copiado'), findsOneWidget))`
- [ ] **Step 2:** `flutter test` → FAIL → implementar → PASS
- [ ] **Step 3:** Commit `feat: integração e fallback para área de transferência`

### Task 6: Release + README

**Files:**
- Create: `.github/workflows/release.yml`, `README.md`

- [ ] **Step 1:** `release.yml` (tag `v*`, `permissions: contents: write`):
  - job windows (`windows-latest`): `flutter build windows --release`; `Compress-Archive build/windows/x64/runner/Release/* teclado-taiwanes-windows.zip`.
  - job macos (`macos-latest`): `flutter build macos --release`; `hdiutil create -volname "Teclado Taiwanes" -srcfolder build/macos/Build/Products/Release/teclado_taiwanes.app -ov -format UDZO teclado-taiwanes-macos.dmg`.
  - job release (needs ambos): `softprops/action-gh-release@v2` com os dois arquivos.
- [ ] **Step 2:** README: uso, como rodar (`flutter run -d windows`), como gerar release (`git tag v1.0.0 && git push --tags`), abrir app não assinado no Mac (clique direito → Abrir; conceder Acessibilidade), checklist de teste manual da spec.
- [ ] **Step 3:** Commit `ci: release Windows e macOS`
- [ ] **Step 4:** Criar repo GitHub `teclado-taiwanes` e push (com confirmação do usuário); empurrar tag `v0.1.0` e verificar Release.
