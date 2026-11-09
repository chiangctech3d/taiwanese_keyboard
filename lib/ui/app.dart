import 'package:flutter/material.dart';

import '../keyboard_state/keyboard_state.dart';
import '../typing/clipboard_fallback.dart';
import '../typing/typer.dart';
import '../update/update_checker.dart';
import 'keyboard_grid.dart';

/// Tamanho do teclado em 100%: 9 teclas de 48 px com 4 px entre elas, mais o
/// respiro de 12 px dos lados; 3 linhas de 44 px com 4 px entre elas, mais 8 px
/// em cima e embaixo.
const Size keyboardSize = Size(488, 156);

class TecladoApp extends StatelessWidget {
  const TecladoApp({
    super.key,
    required this.typer,
    required this.keyboardState,
    required this.isMac,
    this.onOpenSettings,
    this.checkForUpdates,
    this.openUrl,
  });

  final Typer typer;
  final KeyboardState keyboardState;
  final bool isMac;

  /// Abre os Ajustes de Acessibilidade (só no Mac).
  final Future<void> Function()? onOpenSettings;

  /// Consulta de atualização ao abrir e abertura da página de download. Sem
  /// eles o app não verifica.
  final Future<UpdateResult> Function()? checkForUpdates;
  final Future<void> Function(String url)? openUrl;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1D2A44);
    return MaterialApp(
      title: 'Teclado Taiwanês',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: seed),
      darkTheme: ThemeData(colorSchemeSeed: seed, brightness: Brightness.dark),
      home: _Home(
        typer: typer,
        keyboardState: keyboardState,
        isMac: isMac,
        onOpenSettings: onOpenSettings,
        checkForUpdates: checkForUpdates,
        openUrl: openUrl,
      ),
    );
  }
}

class _Home extends StatefulWidget {
  const _Home({
    required this.typer,
    required this.keyboardState,
    required this.isMac,
    required this.onOpenSettings,
    required this.checkForUpdates,
    required this.openUrl,
  });

  final Typer typer;
  final KeyboardState keyboardState;
  final bool isMac;
  final Future<void> Function()? onOpenSettings;
  final Future<UpdateResult> Function()? checkForUpdates;
  final Future<void> Function(String url)? openUrl;

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  @override
  void initState() {
    super.initState();
    _checkUpdates();
  }

  /// Avisa uma vez, ao abrir, se há versão nova; não diz nada nos outros casos.
  Future<void> _checkUpdates() async {
    final check = widget.checkForUpdates;
    if (check == null) return;
    final result = await check();
    if (!mounted || result is! UpdateAvailable) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nova versão ${result.version}'),
        duration: const Duration(seconds: 8),
        action: widget.openUrl == null
            ? null
            : SnackBarAction(
                label: 'Baixar',
                onPressed: () => widget.openUrl!(result.url),
              ),
      ),
    );
  }

  Future<void> _fallback(String text) async {
    final messenger = ScaffoldMessenger.of(context);
    await copyFallback(text);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Copiado — cole com ${widget.isMac ? '⌘V' : 'Ctrl+V'}',
          ),
          duration: const Duration(seconds: 3),
          action: widget.isMac && widget.onOpenSettings != null
              ? SnackBarAction(
                  label: 'Permitir',
                  onPressed: widget.onOpenSettings!,
                )
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
            size: keyboardSize,
            child: KeyboardGrid(
              typer: widget.typer,
              keyboardState: widget.keyboardState,
              onFallback: _fallback,
            ),
          ),
        ),
      ),
    );
  }
}
