import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'typer.dart';

/// Unidades UTF-16 de [s]; o `SendInput` com `KEYEVENTF_UNICODE` envia uma
/// por evento, então diacríticos combinantes vão juntos e na ordem.
List<int> toUtf16Units(String s) => s.codeUnits;

/// Digita no app em foco via `SendInput`, sem modificadores.
class WindowsTyper implements Typer {
  @override
  Future<bool> type(String text) async {
    final units = toUtf16Units(text);
    if (units.isEmpty) return true;
    final count = units.length * 2;
    final inputs = calloc<INPUT>(count);
    try {
      for (var i = 0; i < units.length; i++) {
        for (final (j, up) in [(2 * i, false), (2 * i + 1, true)]) {
          final input = inputs[j];
          input.type = INPUT_KEYBOARD;
          input.Anonymous.ki
            ..wVk = const VIRTUAL_KEY(0)
            ..wScan = units[i]
            ..dwFlags = up
                ? KEYBD_EVENT_FLAGS(KEYEVENTF_UNICODE | KEYEVENTF_KEYUP)
                : KEYEVENTF_UNICODE;
        }
      }
      return SendInput(count, inputs, sizeOf<INPUT>()).value == count;
    } finally {
      calloc.free(inputs);
    }
  }
}
