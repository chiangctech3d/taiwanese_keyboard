import 'dart:ffi' hide Size;
import 'dart:ui';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'window_sizer.dart';

/// Redimensiona a janela do runner (classe criada em win32_window.cpp)
/// mantendo a posição e a moldura.
class WindowsWindowSizer implements WindowSizer {
  @override
  Future<void> setContentSize(Size size) async {
    using((arena) {
      final hwnd = FindWindow(
        arena.pcwstr('FLUTTER_RUNNER_WIN32_WINDOW'),
        null,
      ).value;
      if (hwnd.isNull) return;
      final scale = GetDpiForWindow(hwnd) / 96;
      final window = arena<RECT>();
      final client = arena<RECT>();
      GetWindowRect(hwnd, window);
      GetClientRect(hwnd, client);
      final frameW = (window.ref.right - window.ref.left) - client.ref.right;
      final frameH = (window.ref.bottom - window.ref.top) - client.ref.bottom;
      SetWindowPos(
        hwnd,
        null,
        0,
        0,
        (size.width * scale).round() + frameW,
        (size.height * scale).round() + frameH,
        SET_WINDOW_POS_FLAGS(SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE),
      );
    });
  }
}
