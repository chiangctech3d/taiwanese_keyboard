import 'package:win32/win32.dart';

import 'keyboard_state.dart';

class WindowsKeyboardState implements KeyboardState {
  @override
  bool isShiftDown() => GetAsyncKeyState(VK_SHIFT) & 0x8000 != 0;

  @override
  bool isCapsOn() => GetKeyState(VK_CAPITAL) & 1 != 0;
}
