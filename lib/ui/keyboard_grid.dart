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
    final text = key.of(upperCase: _upper);
    if (_shift == _ShiftMode.once) setState(() => _shift = _ShiftMode.off);
    final ok = await widget.typer.type(text);
    if (!ok) widget.onFallback(text);
  }

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
                _Cell(
                  child: Text(
                    h,
                    style: TextStyle(fontSize: 12, color: scheme.outline),
                  ),
                ),
              const _Cell(),
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
                    onTap: () => _send(pojRows[r][c]),
                  ),
                if (r == 4)
                  _KeyButton(
                    key: const Key('oh'),
                    text: ohNoTone.of(upperCase: _upper),
                    onTap: () => _send(ohNoTone),
                  )
                else
                  const _Cell(),
              ],
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ShiftButton(mode: _shift, onTap: _onShiftTap),
              const SizedBox(width: 8),
              _KeyButton(
                key: const Key('nasal'),
                text: nasal.of(upperCase: _upper),
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
const double _cellHeight = 42;

class _Cell extends StatelessWidget {
  const _Cell({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: _cellWidth,
        height: _cellHeight * 0.6,
        child: Center(child: child),
      );
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  String get _codes => text.runes
      .map((r) => 'U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Tooltip(
        message: _codes,
        waitDuration: const Duration(milliseconds: 600),
        child: Material(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: SizedBox(
              width: _cellWidth - 4,
              height: _cellHeight - 4,
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 20, color: scheme.onSurface),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShiftButton extends StatelessWidget {
  const _ShiftButton({required this.mode, required this.onTap});

  final _ShiftMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = mode != _ShiftMode.off;
    return Material(
      color: active ? scheme.primary : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: const Key('shift'),
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: _cellWidth * 2,
          height: _cellHeight - 4,
          child: Center(
            child: Icon(
              mode == _ShiftMode.locked
                  ? Icons.keyboard_capslock
                  : Icons.arrow_upward,
              color: active ? scheme.onPrimary : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
