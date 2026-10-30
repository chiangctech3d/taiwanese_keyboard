import 'dart:async';

import 'package:flutter/material.dart';

import '../data/poj_chars.dart';
import '../keyboard_state/keyboard_state.dart';
import '../typing/typer.dart';
import 'zoom.dart';

/// Teclado de duas linhas: acentos em cima, letras embaixo.
///
/// Funciona como a tecla morta de um teclado normal: clique no acento e
/// depois na letra. Sem acento, a letra sai simples. Maiúsculas vêm do
/// Shift/Caps Lock físico.
class KeyboardGrid extends StatefulWidget {
  const KeyboardGrid({
    super.key,
    required this.typer,
    required this.keyboardState,
    required this.onFallback,
    this.zoom,
    this.pollInterval = const Duration(milliseconds: 30),
  });

  final Typer typer;
  final KeyboardState keyboardState;

  /// Chamado com o texto quando [Typer.type] falha.
  final void Function(String text) onFallback;

  /// Se presente, mostra A− / A+ no fim da linha dos acentos.
  final ZoomController? zoom;
  final Duration pollInterval;

  @override
  State<KeyboardGrid> createState() => _KeyboardGridState();
}

class _KeyboardGridState extends State<KeyboardGrid> {
  /// Coluna do tom escolhido em [toneHeaders], ou `null`.
  int? _tone;
  bool _upper = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _upper = _readPhysical();
    _poll = Timer.periodic(widget.pollInterval, (_) {
      final upper = _readPhysical();
      if (upper != _upper) setState(() => _upper = upper);
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  bool _readPhysical() =>
      widget.keyboardState.isShiftDown() || widget.keyboardState.isCapsOn();

  PojKey _letterKey(int row) =>
      _tone == null ? baseLetters[row] : pojRows[row][_tone!];

  void _onToneTap(int column) =>
      setState(() => _tone = _tone == column ? null : column);

  Future<void> _send(PojKey key) async {
    // Lê o teclado físico agora: o valor do polling pode ter até 30 ms.
    final text = key.of(upperCase: _readPhysical());
    if (_tone != null) setState(() => _tone = null);
    final ok = await widget.typer.type(text);
    if (!ok) widget.onFallback(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _cellWidth * (baseLetters.length + 1),
            child: Row(
              children: [
                for (var c = 0; c < toneMarks.length; c++)
                  _ToneButton(
                    key: Key('tone-$c'),
                    mark: toneMarks[c],
                    number: toneHeaders[c].split(' ').first,
                    selected: _tone == c,
                    onTap: () => _onToneTap(c),
                  ),
                const Spacer(),
                if (widget.zoom case final zoom?)
                  ListenableBuilder(
                    listenable: zoom,
                    builder: (context, _) => Row(
                      children: [
                        _ZoomButton(
                          key: const Key('zoom-out'),
                          label: 'A−',
                          fontSize: 13,
                          tooltip: 'Diminuir',
                          onTap: zoom.canZoomOut ? zoom.zoomOut : null,
                        ),
                        _ZoomButton(
                          key: const Key('zoom-in'),
                          label: 'A+',
                          fontSize: 17,
                          tooltip: 'Aumentar',
                          onTap: zoom.canZoomIn ? zoom.zoomIn : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var r = 0; r < baseLetters.length; r++)
                _LetterButton(
                  key: Key('letter-$r'),
                  text: _letterKey(r).of(upperCase: _upper),
                  onTap: () => _send(_letterKey(r)),
                ),
              _LetterButton(
                key: const Key('nasal'),
                text: nasal.of(upperCase: _upper),
                showBase: true,
                muted: _tone != null,
                onTap: () => _send(nasal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const double _cellWidth = 48;
const double _gap = 2;
final _radius = BorderRadius.circular(6);

/// Tecla sem ondulação (padrão desktop): só muda de cor no hover e no clique.
class _KeySurface extends StatelessWidget {
  const _KeySurface({
    required this.height,
    required this.color,
    required this.onTap,
    required this.child,
  });

  final double height;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(_gap),
      child: Material(
        color: color,
        borderRadius: _radius,
        child: InkWell(
          borderRadius: _radius,
          splashFactory: NoSplash.splashFactory,
          hoverColor: scheme.onSurface.withValues(alpha: 0.06),
          highlightColor: scheme.onSurface.withValues(alpha: 0.12),
          onTap: onTap,
          child: SizedBox(
            width: _cellWidth - 2 * _gap,
            height: height - 2 * _gap,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _ToneButton extends StatelessWidget {
  const _ToneButton({
    super.key,
    required this.mark,
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final String mark;
  final String number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    return Tooltip(
      message: 'Tom $number · clique e depois na letra',
      waitDuration: const Duration(milliseconds: 600),
      child: _KeySurface(
        height: 40,
        color: selected ? scheme.primary : scheme.surfaceContainer,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(mark, style: TextStyle(fontSize: 22, color: fg)),
            Text(
              number,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? fg : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    super.key,
    required this.label,
    required this.fontSize,
    required this.tooltip,
    required this.onTap,
  });

  final String label;
  final double fontSize;
  final String tooltip;

  /// `null` no limite da escala.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: _KeySurface(
        height: 40,
        color: Colors.transparent,
        onTap: onTap ?? () {},
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: enabled
                ? scheme.onSurfaceVariant
                : scheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

class _LetterButton extends StatelessWidget {
  const _LetterButton({
    super.key,
    required this.text,
    required this.onTap,
    this.showBase = false,
    this.muted = false,
  });

  final String text;
  final VoidCallback onTap;

  /// Mostra o círculo pontilhado (◌) antes do texto, apagado, para indicar
  /// que a marca se junta à letra anterior (ex.: ⁿ não é um "n").
  final bool showBase;

  /// Apagada enquanto um acento está escolhido (o ⁿ não recebe acento).
  final bool muted;

  String get _codes => text.runes
      .map((r) => 'U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = muted
        ? scheme.onSurface.withValues(alpha: 0.38)
        : scheme.onSurface;
    return Tooltip(
      message: _codes,
      waitDuration: const Duration(milliseconds: 600),
      child: _KeySurface(
        height: 52,
        color: scheme.surfaceContainerHigh,
        onTap: onTap,
        child: Text.rich(
          TextSpan(
            children: [
              if (showBase)
                TextSpan(
                  text: '◌',
                  style: TextStyle(
                    fontSize: 18,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              TextSpan(text: text),
            ],
          ),
          style: TextStyle(fontSize: 27, height: 1.1, color: fg),
        ),
      ),
    );
  }
}
