import 'dart:async';

import 'package:flutter/material.dart';

import '../data/poj_chars.dart';
import '../keyboard_state/keyboard_state.dart';
import '../typing/typer.dart';

/// Estado do ⇧ da tela: um toque arma para uma letra; dois toques seguidos
/// travam; outro toque solta.
enum ShiftState { off, armed, locked }

/// Teclado de três linhas (Keyboard Rows Rule do design_louvor): acentos,
/// letras com o ⁿ, e ⇧ e ⌫ embaixo.
///
/// O acento é tecla morta: clique nele e depois na letra. Sem acento, a letra
/// sai simples. Maiúsculas vêm do ⇧ da tela, do Shift ou do Caps Lock físico.
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
  static const _doubleTap = Duration(milliseconds: 400);
  static const _repeatDelay = Duration(milliseconds: 400);
  static const _repeatEvery = Duration(milliseconds: 80);

  /// Coluna do tom escolhido em [toneHeaders], ou `null`.
  int? _tone;
  ShiftState _shift = ShiftState.off;
  DateTime _lastShiftTap = DateTime.fromMillisecondsSinceEpoch(0);
  bool _physicalUpper = false;
  Timer? _poll;
  Timer? _repeat;

  @override
  void initState() {
    super.initState();
    _physicalUpper = _readPhysical();
    _poll = Timer.periodic(widget.pollInterval, (_) {
      final upper = _readPhysical();
      if (upper != _physicalUpper) setState(() => _physicalUpper = upper);
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _repeat?.cancel();
    super.dispose();
  }

  bool _readPhysical() =>
      widget.keyboardState.isShiftDown() || widget.keyboardState.isCapsOn();

  bool get _upper => _shift != ShiftState.off || _physicalUpper;

  PojKey _letterKey(int row) =>
      _tone == null ? baseLetters[row] : pojRows[row][_tone!];

  void _onToneTap(int column) =>
      setState(() => _tone = _tone == column ? null : column);

  void _onShiftTap() {
    final now = DateTime.now();
    setState(() {
      _shift = switch (_shift) {
        ShiftState.off => ShiftState.armed,
        ShiftState.armed when now.difference(_lastShiftTap) < _doubleTap =>
          ShiftState.locked,
        _ => ShiftState.off,
      };
      _lastShiftTap = now;
    });
  }

  Future<void> _send(PojKey key) async {
    // Lê o teclado físico agora: o valor do polling pode ter até 30 ms.
    final text = key.of(upperCase: _readPhysical() || _shift != ShiftState.off);
    setState(() {
      _tone = null;
      if (_shift == ShiftState.armed) _shift = ShiftState.off;
    });
    final ok = await widget.typer.type(text);
    if (!ok) widget.onFallback(text);
  }

  Future<void> _backspace() => widget.typer.backspace();

  void _startRepeat() {
    _repeat?.cancel();
    _repeat = Timer(_repeatDelay, () {
      _backspace();
      _repeat = Timer.periodic(_repeatEvery, (_) => _backspace());
    });
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surfaceContainerHigh),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _padX, vertical: _padY),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row([
              for (var c = 0; c < toneMarks.length; c++)
                _Key(
                  key: Key('tone-$c'),
                  width: _keyWidth,
                  tooltip: 'Tom ${toneHeaders[c].split(' ').first}',
                  armed: _tone == c,
                  onTap: () => _onToneTap(c),
                  child: _ToneGlyph(
                    mark: toneMarks[c],
                    number: toneHeaders[c].split(' ').first,
                    armed: _tone == c,
                  ),
                ),
            ]),
            const SizedBox(height: _gap),
            _row([
              for (var r = 0; r < baseLetters.length; r++)
                _LetterKey(
                  key: Key('letter-$r'),
                  text: _letterKey(r).of(upperCase: _upper),
                  hint: _tone == null
                      ? null
                      : 'tom ${toneHeaders[_tone!].split(' ').first}',
                  onTap: () => _send(_letterKey(r)),
                ),
              _LetterKey(
                key: const Key('nasal'),
                text: nasal.of(upperCase: _upper),
                hint: _tone == null ? 'nasalização' : 'não recebe acento',
                // Desativado enquanto há acento escolhido.
                onTap: _tone == null ? () => _send(nasal) : null,
              ),
            ]),
            const SizedBox(height: _gap),
            SizedBox(
              width: _keyWidth * (baseLetters.length + 1) +
                  _gap * baseLetters.length,
              child: Row(
                children: [
                  _Key(
                    key: const Key('shift'),
                    width: _wideKeyWidth,
                    tooltip: switch (_shift) {
                      ShiftState.off => 'Maiúscula',
                      ShiftState.armed => 'Maiúscula (duplo toque trava)',
                      ShiftState.locked => 'Maiúscula travada',
                    },
                    armed: _shift != ShiftState.off,
                    locked: _shift == ShiftState.locked,
                    onTap: _onShiftTap,
                    child: const _KeyIcon(Icons.arrow_upward),
                  ),
                  const Spacer(),
                  // ⌫ apertado apaga de novo depois de 400 ms, a cada 80 ms.
                  Listener(
                    onPointerDown: (_) => _startRepeat(),
                    onPointerUp: (_) => _stopRepeat(),
                    onPointerCancel: (_) => _stopRepeat(),
                    child: _Key(
                      key: const Key('backspace'),
                      width: _wideKeyWidth,
                      tooltip: 'Apagar',
                      onTap: _backspace,
                      child: const _KeyIcon(Icons.backspace_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<Widget> keys) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < keys.length; i++) ...[
            if (i > 0) const SizedBox(width: _gap),
            keys[i],
          ],
        ],
      );
}

const double _keyWidth = 48;
const double _wideKeyWidth = 72;
const double _keyHeight = 44;
const double _gap = 4;
const double _padX = 12;
const double _padY = 8;
final _radius = BorderRadius.circular(4);

/// Tecla de 44 px: folha com linha forte; armada, tinta com ponto de 6 px
/// (Armed Rule); travada, sublinhada; sem ação, desativada em tom neutro.
class _Key extends StatefulWidget {
  const _Key({
    super.key,
    required this.width,
    required this.child,
    required this.onTap,
    this.tooltip,
    this.armed = false,
    this.locked = false,
  });

  final double width;
  final Widget child;

  /// `null` desativa a tecla: sem hover, sem clique.
  final VoidCallback? onTap;
  final String? tooltip;
  final bool armed;
  final bool locked;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = widget.onTap != null;
    final armed = enabled && widget.armed;
    final Color fill = armed ? scheme.onSurface : scheme.surface;
    final Color fg = !enabled
        ? scheme.onSurfaceVariant
        : armed
            ? scheme.surface
            : scheme.onSurface;
    final Color border = !enabled
        ? scheme.outlineVariant
        : armed
            ? scheme.onSurface
            : _hover
                ? scheme.onSurfaceVariant
                : scheme.outline;
    Widget key = MouseRegion(
      onEnter: (_) => setState(() => _hover = enabled),
      onExit: (_) => setState(() => _hover = false),
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: _KeyColors(
          color: fg,
          hover: _hover && enabled,
          child: Container(
            width: widget.width,
            height: _keyHeight,
            decoration: BoxDecoration(
              color: fill,
              border: Border.all(color: border),
              borderRadius: _radius,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                widget.child,
                if (widget.locked)
                  Positioned(
                    bottom: 7,
                    child: Container(width: 18, height: 2, color: fg),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (widget.tooltip != null) {
      key = Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 600),
        child: key,
      );
    }
    return key;
  }
}

/// Repassa a cor e o hover da tecla para o conteúdo.
class _KeyColors extends InheritedWidget {
  const _KeyColors({
    required this.color,
    required this.hover,
    required super.child,
  });

  final Color color;
  final bool hover;

  static _KeyColors of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_KeyColors>()!;

  @override
  bool updateShouldNotify(_KeyColors old) =>
      color != old.color || hover != old.hover;
}

class _KeyIcon extends StatelessWidget {
  const _KeyIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) =>
      Icon(icon, size: 20, color: _KeyColors.of(context).color);
}

/// Tecla de tom: o sinal desenhado no centro e o número no canto de cima.
class _ToneGlyph extends StatelessWidget {
  const _ToneGlyph({
    required this.mark,
    required this.number,
    required this.armed,
  });

  final String mark;
  final String number;
  final bool armed;

  @override
  Widget build(BuildContext context) {
    final colors = _KeyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Com mouse, o sinal sob o ponteiro cresce 1,35× em 120 ms.
        AnimatedScale(
          scale: colors.hover ? 1.35 : 1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 120),
          child: CustomPaint(
            size: const Size(32, 32),
            painter: _SignPainter(mark, colors.color),
          ),
        ),
        Positioned(
          top: 2,
          right: 5,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 12,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: armed ? scheme.surface : scheme.onSurfaceVariant,
            ),
          ),
        ),
        if (armed)
          Positioned(
            top: 3,
            left: 3,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

/// Traços de cada sinal num quadro de 24×24 (os mesmos do design_louvor).
const Map<String, List<List<Offset>>> _strokes = {
  '´': [
    [Offset(9, 16), Offset(15, 8)],
  ],
  '`': [
    [Offset(9, 8), Offset(15, 16)],
  ],
  'ˆ': [
    [Offset(7, 15), Offset(12, 8), Offset(17, 15)],
  ],
  '¯': [
    [Offset(5, 12), Offset(19, 12)],
  ],
  'ˈ': [
    [Offset(12, 5), Offset(12, 19)],
  ],
  // Tom 9: caron, um V.
  'ˇ': [
    [Offset(6, 9), Offset(12, 16), Offset(18, 9)],
  ],
};

class _SignPainter extends CustomPainter {
  _SignPainter(this.mark, this.color);

  final String mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (final line in _strokes[mark] ?? const <List<Offset>>[]) {
      path.moveTo(line.first.dx * k, line.first.dy * k);
      for (final p in line.skip(1)) {
        path.lineTo(p.dx * k, p.dy * k);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SignPainter old) => old.mark != mark || old.color != color;
}

class _LetterKey extends StatelessWidget {
  const _LetterKey({
    super.key,
    required this.text,
    required this.onTap,
    this.hint,
  });

  final String text;

  /// `null` = tecla desativada (o ⁿ não recebe acento).
  final VoidCallback? onTap;

  /// Vai no tooltip entre o caractere e o código (ex.: "tom 5").
  final String? hint;

  String get _codes => text.runes
      .map((r) => 'U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return _Key(
      width: _keyWidth,
      tooltip: [text, ?hint, _codes].join(' · '),
      onTap: onTap,
      child: Builder(
        builder: (context) => Text(
          text,
          style: TextStyle(
            fontSize: 16,
            height: 1,
            color: _KeyColors.of(context).color,
          ),
        ),
      ),
    );
  }
}
