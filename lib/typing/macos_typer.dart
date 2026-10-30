import 'package:flutter/services.dart';

import '../native/macos_channel.dart';
import 'typer.dart';

/// Digita via `CGEvent` no Swift; retorna `false` sem permissão de
/// Acessibilidade.
class MacosTyper implements Typer {
  @override
  Future<bool> type(String text) async {
    try {
      return await macosChannel.invokeMethod<bool>('type', text) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
