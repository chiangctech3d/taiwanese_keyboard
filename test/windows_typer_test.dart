import 'package:flutter_test/flutter_test.dart';
import 'package:teclado_taiwanes/typing/windows_typer.dart';

void main() {
  test('combinante vira 3 unidades UTF-16', () {
    expect(toUtf16Units('o̍͘').length, 3);
  });

  test('pré-composto vira 1 unidade', () {
    expect(toUtf16Units('á'), [0xE1]);
  });

  test('fora do BMP vira par substituto', () {
    expect(toUtf16Units('\u{1D11E}'), [0xD834, 0xDD1E]);
  });
}
