import 'package:flutter_test/flutter_test.dart';
import 'package:teclado_taiwanes/data/poj_chars.dart';

void main() {
  test('8 linhas x 6 tons', () {
    expect(toneHeaders.length, 6);
    expect(pojRows.length, 8);
    for (final r in pojRows) {
      expect(r.length, 6);
    }
  });

  test('valores exatos', () {
    expect(pojRows[0][0].lower, 'á');
    expect(pojRows[0][4].lower, 'a̍');
    expect(pojRows[4][4].lower, 'o̍͘');
    expect(pojRows[4][4].upper, 'O̍͘');
    expect(pojRows[7][1].upper, 'Ǹ');
    expect(ohNoTone.lower, 'o͘');
    expect(nasal.upper, 'ᴺ');
  });

  test('maiúscula de toda tecla é diferente da minúscula', () {
    for (final r in pojRows) {
      for (final k in r) {
        expect(k.upper, isNot(k.lower));
      }
    }
  });

  test('8 letras base na ordem das linhas', () {
    expect(baseLetters.map((k) => k.lower).join(' '),
        'a e i o o͘ u m n');
    expect(baseLetters[4].upper, 'O͘');
  });
}
