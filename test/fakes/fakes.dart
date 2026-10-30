import 'package:teclado_taiwanes/keyboard_state/keyboard_state.dart';
import 'package:teclado_taiwanes/typing/typer.dart';

class FakeTyper implements Typer {
  FakeTyper({this.result = true});

  final bool result;
  final List<String> typed = [];

  @override
  Future<bool> type(String text) async {
    typed.add(text);
    return result;
  }
}

class FakeKeyboardState implements KeyboardState {
  bool shift = false;
  bool caps = false;

  @override
  bool isShiftDown() => shift;

  @override
  bool isCapsOn() => caps;
}
