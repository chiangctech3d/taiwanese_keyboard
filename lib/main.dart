import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'keyboard_state/keyboard_state.dart';
import 'keyboard_state/macos_keyboard_state.dart';
import 'keyboard_state/windows_keyboard_state.dart';
import 'native/macos_channel.dart';
import 'typing/macos_typer.dart';
import 'typing/typer.dart';
import 'typing/windows_typer.dart';
import 'ui/app.dart';
import 'ui/zoom.dart';
import 'update/update_checker.dart';
import 'window/macos_window_sizer.dart';
import 'window/window_sizer.dart';
import 'window/windows_window_sizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Typer typer;
  final KeyboardState keyboardState;
  final WindowSizer windowSizer;
  if (Platform.isMacOS) {
    typer = MacosTyper();
    keyboardState = MacosKeyboardState();
    windowSizer = MacosWindowSizer();
    requestAccessibility();
  } else {
    typer = WindowsTyper();
    keyboardState = WindowsKeyboardState();
    windowSizer = WindowsWindowSizer();
  }

  // Aplica o tamanho salvo na última execução.
  final zoom = await ZoomController.load();
  final info = await PackageInfo.fromPlatform();
  await windowSizer.setContentSize(zoom.contentSize);

  runApp(
    TecladoApp(
      typer: typer,
      keyboardState: keyboardState,
      isMac: Platform.isMacOS,
      onOpenSettings: Platform.isMacOS ? openAccessibilitySettings : null,
      zoom: zoom,
      windowSizer: windowSizer,
      version: info.version,
      checkForUpdates: UpdateChecker(currentVersion: info.version).check,
      openUrl: (url) => launchUrl(Uri.parse(url)),
      checkUpdatesOnStart: true,
    ),
  );
}
