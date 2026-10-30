import 'dart:io';

import 'package:flutter/material.dart';

import 'keyboard_state/keyboard_state.dart';
import 'keyboard_state/macos_keyboard_state.dart';
import 'keyboard_state/windows_keyboard_state.dart';
import 'native/macos_channel.dart';
import 'typing/macos_typer.dart';
import 'typing/typer.dart';
import 'typing/windows_typer.dart';
import 'ui/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final Typer typer;
  final KeyboardState keyboardState;
  if (Platform.isMacOS) {
    typer = MacosTyper();
    keyboardState = MacosKeyboardState();
    requestAccessibility();
  } else {
    typer = WindowsTyper();
    keyboardState = WindowsKeyboardState();
  }

  runApp(TecladoApp(
    typer: typer,
    keyboardState: keyboardState,
    isMac: Platform.isMacOS,
    onOpenSettings: Platform.isMacOS ? openAccessibilitySettings : null,
  ));
}
