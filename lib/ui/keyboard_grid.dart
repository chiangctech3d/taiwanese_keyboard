import 'dart:async';

import 'package:flutter/material.dart';

import '../data/poj_chars.dart';
import '../keyboard_state/keyboard_state.dart';
import '../typing/typer.dart';

enum _ShiftMode { off, once, locked }

/// Grade de teclas POJ com Shift virtual que também segue o Shift/Caps físico.
class KeyboardGrid extends StatefulWidget {
  const KeyboardGrid({
    super.key,
    required this.typer,
    required this.keyboardState,
    required this.onFallback,
    this.pollInterval = const Duration(milliseconds: 30),
  });

  final Typer typer;
  final KeyboardState keyboardState;

  /// Chamado com o texto quando [Typer.type] falha.
  final void Function(String text) onFallback;
  final Duration pollInterval;

  @override
  State<KeyboardGrid> createState() => _KeyboardGridState();
}

class _KeyboardGridState extends State<KeyboardGrid> {
  static const _doubleTapWindow = Duration(milliseconds: 300);

  _ShiftMode _shift = _ShiftMode.off;
  bool _physicalUpper = false;
  Timer? _poll;
  Timer? _doubleTap;

  bool get _upper => _physicalUpper || _shift != _ShiftMode.off;

  @override
  void initState() {
    super.initState();
    _physicalUpper = _readPhysical();
    _poll = Timer.periodic(widget.pollInterval, (_) {
      final physical = _readPhysical();
      if (physical != _physicalUpper) setState(() => _physicalUpper = physical);
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _doubleTap?.cancel();
    super.dispose();
  }

  bool _readPhysical() =>
      widget.keyboardState.isShiftDown() || widget.keyboardState.isCapsOn();

  void _onShiftTap() {
    final secondTap = _doubleTap?.isActive ?? false;
    _doubleTap?.cancel();
    setState(() {
      if (secondTap && _shift == _ShiftMode.once) {
        _shift = _ShiftMode.locked;
      } else if (_shift == _ShiftMode.off) {
        _shift = _ShiftMode.once;
        _doubleTap = Timer(_doubleTapWindow, () {});
      } else {
        _shift = _ShiftMode.off;
      }
    });
  }

  Future<void> _send(PojKey key) async {
    // Lê o teclado físico agora: o valor do polling pode ter até 30 ms.
    final upper = _readPhysical() || _shift != _ShiftMode.off;
    final text = key.of(upperCase: upper);
    if (_shift == _ShiftMode.once) setState(() => _shift = _ShiftMode.off);
    final ok = await widget.typer.type(text);
    if (!ok) widget.onFallback(text);
  }

  _ShiftLook get _shiftLook => switch (_shift) {
        _ShiftMode.locked => _ShiftLook.locked,
        _ShiftMode.once => _ShiftLook.once,
        _ShiftMode.off when _physicalUpper => _ShiftLook.physical,
        _ShiftMode.off => _ShiftLook.off,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final h in toneHeaders)
                SizedBox(
                  width: _cellWidth,
                  height: 20,
                  child: Center(
                    child: Text(
                      h.split(' ').first,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          for (var r = 0; r < pojRows.length; r++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var c = 0; c < pojRows[r].length; c++)
                  _KeyButton(
                    key: Key('k-$r-$c'),
                    text: pojRows[r][c].of(upperCase: _upper),
                    hint: 'Tom ${toneHeaders[c].split(' ').first}',
                    onTap: () => _send(pojRows[r][c]),
                  ),
              ],
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ShiftButton(look: _shiftLook, onTap: _onShiftTap),
              _KeyButton(
                key: const Key('oh'),
                text: ohNoTone.of(upperCase: _upper),
                hint: 'o͘ sem tom',
                onTap: () => _send(ohNoTone),
              ),
              _KeyButton(
                key: const Key('nasal'),
                text: nasal.of(upperCase: _upper),
                showBase: true,
                hint: 'Nasalização',
                onTap: () => _send(nasal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const double _cellWidth = 52;
const double _cellHeight = 44;
const double _gap = 2;
final _radius = BorderRadius.circular(6);

/// Tecla sem ondulação (padrão desktop): só muda de cor no hover e no clique.
class _KeySurface extends StatelessWidget {
  const _KeySurface({
    required this.width,
    required this.color,
    required this.onTap,
    required this.child,
    this.inkKey,
  });

  final double width;
  final Color color;
  final VoidCallback onTap;
  final Widget child;
  final Key? inkKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(_gap),
      child: Material(
        color: color,
        borderRadius: _radius,
        child: InkWell(
          key: inkKey,
          borderRadius: _radius,
          splashFactory: NoSplash.splashFactory,
          hoverColor: scheme.onSurface.withValues(alpha: 0.06),
          highlightColor: scheme.onSurface.withValues(alpha: 0.12),
          onTap: onTap,
          child: SizedBox(
            width: width - 2 * _gap,
            height: _cellHeight - 2 * _gap,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    super.key,
    required this.text,
    required this.hint,
    required this.onTap,
    this.showBase = false,
  });

  final String text;
  final String hint;

  /// Mostra o círculo pontilhado (◌) antes do texto, apagado, para indicar
  /// que a marca se junta à letra anterior (ex.: ⁿ não é um "n").
  final bool showBase;
  final VoidCallback onTap;

  String get _codes => text.runes
      .map((r) => 'U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: '$hint · $_codes',
      waitDuration: const Duration(milliseconds: 600),
      child: _KeySurface(
        width: _cellWidth,
        color: scheme.surfaceContainerHigh,
        onTap: onTap,
        child: Text.rich(
          TextSpan(children: [
            if (showBase)
              TextSpan(
                text: '◌',
                style: TextStyle(
                  fontSize: 18,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            TextSpan(text: text),
          ]),
          style: TextStyle(fontSize: 27, height: 1.1, color: scheme.onSurface),
        ),
      ),
    );
  }
}

enum _ShiftLook { off, physical, once, locked }

class _ShiftButton extends StatelessWidget {
  const _ShiftButton({required this.look, required this.onTap});

  final _ShiftLook look;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (look) {
      _ShiftLook.off => (scheme.surfaceContainerHigh, scheme.onSurface),
      _ShiftLook.physical => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer
        ),
      _ShiftLook.once || _ShiftLook.locked => (scheme.primary, scheme.onPrimary),
    };
    final label = switch (look) {
      _ShiftLook.physical => 'Shift físico',
      _ShiftLook.locked => 'Shift fixo',
      _ => 'Shift',
    };
    return Tooltip(
      message: 'Clique: próxima letra maiúscula · Duplo clique: fixar',
      waitDuration: const Duration(milliseconds: 600),
      child: _KeySurface(
        inkKey: const Key('shift'),
        width: _cellWidth * 4,
        color: bg,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              look == _ShiftLook.locked
                  ? Icons.keyboard_capslock
                  : Icons.arrow_upward,
              size: 20,
              color: fg,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
