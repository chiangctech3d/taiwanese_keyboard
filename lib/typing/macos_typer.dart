import '../native/macos_channel.dart';
import 'typer.dart';

/// Digita via `CGEvent` no Swift; retorna `false` sem permissão de
/// Acessibilidade.
class MacosTyper implements Typer {
  @override
  Future<bool> type(String text) async =>
      await macosChannel.invokeMethod<bool>('type', text) ?? false;
}
