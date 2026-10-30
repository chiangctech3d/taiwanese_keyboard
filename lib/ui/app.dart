import 'package:flutter/material.dart';

import '../keyboard_state/keyboard_state.dart';
import '../typing/clipboard_fallback.dart';
import '../typing/typer.dart';
import 'keyboard_grid.dart';

class TecladoApp extends StatelessWidget {
  const TecladoApp({
    super.key,
    required this.typer,
    required this.keyboardState,
    required this.isMac,
    this.onOpenSettings,
  });

  final Typer typer;
  final KeyboardState keyboardState;
  final bool isMac;

  /// Abre os Ajustes de Acessibilidade (só no Mac).
  final Future<void> Function()? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF2E7D6B);
    return MaterialApp(
      title: 'Teclado Taiwanês',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: seed),
      darkTheme:
          ThemeData(colorSchemeSeed: seed, brightness: Brightness.dark),
      home: _Home(
        typer: typer,
        keyboardState: keyboardState,
        isMac: isMac,
        onOpenSettings: onOpenSettings,
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({
    required this.typer,
    required this.keyboardState,
    required this.isMac,
    required this.onOpenSettings,
  });

  final Typer typer;
  final KeyboardState keyboardState;
  final bool isMac;
  final Future<void> Function()? onOpenSettings;

  Future<void> _fallback(BuildContext context, String text) async {
    final messenger = ScaffoldMessenger.of(context);
    await copyFallback(text);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Copiado — cole com ${isMac ? '⌘V' : 'Ctrl+V'}'),
        duration: const Duration(seconds: 3),
        action: isMac && onOpenSettings != null
            ? SnackBarAction(label: 'Permitir', onPressed: onOpenSettings!)
            : null,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: KeyboardGrid(
            typer: typer,
            keyboardState: keyboardState,
            onFallback: (text) => _fallback(context, text),
          ),
        ),
      ),
    );
  }
}
