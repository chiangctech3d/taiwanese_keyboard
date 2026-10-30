import 'dart:async';

import 'package:flutter/services.dart';

import '../native/macos_channel.dart';
import 'keyboard_state.dart';

/// O canal é assíncrono e a interface é síncrona: guarda o último valor lido
/// e atualiza com polling próprio.
class MacosKeyboardState implements KeyboardState {
  MacosKeyboardState({Duration interval = const Duration(milliseconds: 30)}) {
    _timer = Timer.periodic(interval, (_) => _refresh());
  }

  late final Timer _timer;
  bool _shift = false;
  bool _caps = false;
  bool _busy = false;

  Future<void> _refresh() async {
    if (_busy) return;
    _busy = true;
    try {
      final m = await macosChannel.invokeMapMethod<String, bool>('modifiers');
      _shift = m?['shift'] ?? false;
      _caps = m?['caps'] ?? false;
    } on PlatformException {
      // Mantém o último valor.
    } on MissingPluginException {
      // Mantém o último valor.
    } finally {
      _busy = false;
    }
  }

  void dispose() => _timer.cancel();

  @override
  bool isShiftDown() => _shift;

  @override
  bool isCapsOn() => _caps;
}
