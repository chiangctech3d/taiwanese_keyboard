import 'package:flutter/material.dart';

import '../keyboard_state/keyboard_state.dart';
import '../typing/clipboard_fallback.dart';
import '../typing/typer.dart';
import '../window/window_sizer.dart';
import 'keyboard_grid.dart';
import 'zoom.dart';

class TecladoApp extends StatefulWidget {
  const TecladoApp({
    super.key,
    required this.typer,
    required this.keyboardState,
    required this.isMac,
    this.onOpenSettings,
    this.zoom,
    this.windowSizer,
    this.version,
  });

  final Typer typer;
  final KeyboardState keyboardState;
  final bool isMac;

  /// Abre os Ajustes de Acessibilidade (só no Mac).
  final Future<void> Function()? onOpenSettings;

  /// Tamanho do teclado (A− / A+); a janela acompanha via [windowSizer].
  final ZoomController? zoom;
  final WindowSizer? windowSizer;

  /// Versão do programa, mostrada no teclado.
  final String? version;

  @override
  State<TecladoApp> createState() => _TecladoAppState();
}

class _TecladoAppState extends State<TecladoApp> {
  @override
  void initState() {
    super.initState();
    widget.zoom?.addListener(_resize);
  }

  @override
  void dispose() {
    widget.zoom?.removeListener(_resize);
    super.dispose();
  }

  void _resize() {
    final zoom = widget.zoom;
    if (zoom != null) widget.windowSizer?.setContentSize(zoom.contentSize);
  }

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF2E7D6B);
    return MaterialApp(
      title: 'Teclado Taiwanês',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: seed),
      darkTheme: ThemeData(colorSchemeSeed: seed, brightness: Brightness.dark),
      home: _Home(
        typer: widget.typer,
        keyboardState: widget.keyboardState,
        isMac: widget.isMac,
        onOpenSettings: widget.onOpenSettings,
        zoom: widget.zoom,
        version: widget.version,
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
    required this.zoom,
    required this.version,
  });

  final Typer typer;
  final KeyboardState keyboardState;
  final bool isMac;
  final Future<void> Function()? onOpenSettings;
  final ZoomController? zoom;
  final String? version;

  Future<void> _fallback(BuildContext context, String text) async {
    final messenger = ScaffoldMessenger.of(context);
    await copyFallback(text);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Copiado — cole com ${isMac ? '⌘V' : 'Ctrl+V'}'),
          duration: const Duration(seconds: 3),
          action: isMac && onOpenSettings != null
              ? SnackBarAction(label: 'Permitir', onPressed: onOpenSettings!)
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O teclado é desenhado em 100% e escalado para caber na janela.
      body: SizedBox.expand(
        child: FittedBox(
          child: SizedBox.fromSize(
            size: baseContentSize,
            child: KeyboardGrid(
              typer: typer,
              keyboardState: keyboardState,
              onFallback: (text) => _fallback(context, text),
              zoom: zoom,
              version: version,
            ),
          ),
        ),
      ),
    );
  }
}
