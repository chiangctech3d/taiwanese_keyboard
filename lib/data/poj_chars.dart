/// Tabela de caracteres POJ (Pe̍h-ōe-jī) do teclado virtual.
///
/// Os caracteres são `String` porque vários só existem como letra base +
/// diacrítico combinante (ex.: a̍ = `a̍`, o͘ = `o͘`).
library;

class PojKey {
  const PojKey(this.lower, this.upper);

  final String lower;
  final String upper;

  String of({required bool upperCase}) => upperCase ? upper : lower;
}

/// Cabeçalho das colunas: número do tom e sua marca.
const List<String> toneHeaders = ['2 ´', '3 `', '5 ^', '7 ¯', '8 ̍', '9 ˇ'];

/// 8 linhas (a, e, i, o, o͘, u, m, n) × 6 tons, na ordem de [toneHeaders].
const List<List<PojKey>> pojRows = [
  [
    PojKey('á', 'Á'),
    PojKey('à', 'À'),
    PojKey('â', 'Â'),
    PojKey('ā', 'Ā'),
    PojKey('a̍', 'A̍'),
    PojKey('ǎ', 'Ǎ'),
  ],
  [
    PojKey('é', 'É'),
    PojKey('è', 'È'),
    PojKey('ê', 'Ê'),
    PojKey('ē', 'Ē'),
    PojKey('e̍', 'E̍'),
    PojKey('ě', 'Ě'),
  ],
  [
    PojKey('í', 'Í'),
    PojKey('ì', 'Ì'),
    PojKey('î', 'Î'),
    PojKey('ī', 'Ī'),
    PojKey('i̍', 'I̍'),
    PojKey('ǐ', 'Ǐ'),
  ],
  [
    PojKey('ó', 'Ó'),
    PojKey('ò', 'Ò'),
    PojKey('ô', 'Ô'),
    PojKey('ō', 'Ō'),
    PojKey('o̍', 'O̍'),
    PojKey('ǒ', 'Ǒ'),
  ],
  [
    PojKey('ó͘', 'Ó͘'),
    PojKey('ò͘', 'Ò͘'),
    PojKey('ô͘', 'Ô͘'),
    PojKey('ō͘', 'Ō͘'),
    PojKey('o̍͘', 'O̍͘'),
    PojKey('ǒ͘', 'Ǒ͘'),
  ],
  [
    PojKey('ú', 'Ú'),
    PojKey('ù', 'Ù'),
    PojKey('û', 'Û'),
    PojKey('ū', 'Ū'),
    PojKey('u̍', 'U̍'),
    PojKey('ǔ', 'Ǔ'),
  ],
  [
    PojKey('ḿ', 'Ḿ'),
    PojKey('m̀', 'M̀'),
    PojKey('m̂', 'M̂'),
    PojKey('m̄', 'M̄'),
    PojKey('m̍', 'M̍'),
    PojKey('m̆', 'M̆'),
  ],
  [
    PojKey('ń', 'Ń'),
    PojKey('ǹ', 'Ǹ'),
    PojKey('n̂', 'N̂'),
    PojKey('n̄', 'N̄'),
    PojKey('n̍', 'N̍'),
    PojKey('n̆', 'N̆'),
  ],
];

/// Letras base, na mesma ordem das linhas de [pojRows].
const List<PojKey> baseLetters = [
  PojKey('a', 'A'),
  PojKey('e', 'E'),
  PojKey('i', 'I'),
  PojKey('o', 'O'),
  ohNoTone,
  PojKey('u', 'U'),
  PojKey('m', 'M'),
  PojKey('n', 'N'),
];

/// o͘ sem marca de tom.
const PojKey ohNoTone = PojKey('o͘', 'O͘');

/// Marca de cada tom, na forma isolada (sem letra), na ordem de
/// [toneHeaders]. Tom 5 = circunflexo (U+02C6), tom 9 = caron (U+02C7,
/// a meia-lua), tom 8 = linha vertical (U+02C8).
const List<String> toneMarks = ['´', '`', 'ˆ', '¯', 'ˈ', 'ˇ'];

/// Nasalização.
const PojKey nasal = PojKey('ⁿ', 'ᴺ');
