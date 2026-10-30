import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teclado_taiwanes/ui/keyboard_grid.dart';

import 'fakes/fakes.dart';

void main() {
  late FakeTyper typer;
  late FakeKeyboardState keys;
  late List<String> fallback;

  Future<void> pumpGrid(WidgetTester tester, {bool typeResult = true}) async {
    typer = FakeTyper(result: typeResult);
    keys = FakeKeyboardState();
    fallback = [];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: KeyboardGrid(
          typer: typer,
          keyboardState: keys,
          onFallback: fallback.add,
        ),
      ),
    ));
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pump();
  }

  testWidgets('letra sem acento digita a letra simples', (tester) async {
    await pumpGrid(tester);
    await tap(tester, 'letter-0');
    await tap(tester, 'letter-4');
    expect(typer.typed, ['a', 'o͘']);
  });

  testWidgets('acento + letra digita a combinação e desmarca o acento',
      (tester) async {
    await pumpGrid(tester);
    await tap(tester, 'tone-0');
    await tap(tester, 'letter-0');
    await tap(tester, 'letter-0');
    expect(typer.typed, ['á', 'a']);
  });

  testWidgets('clicar no acento de novo desmarca', (tester) async {
    await pumpGrid(tester);
    await tap(tester, 'tone-0');
    await tap(tester, 'tone-0');
    await tap(tester, 'letter-0');
    expect(typer.typed, ['a']);
  });

  testWidgets('outro acento substitui o escolhido', (tester) async {
    await pumpGrid(tester);
    await tap(tester, 'tone-0');
    await tap(tester, 'tone-3');
    await tap(tester, 'letter-1');
    expect(typer.typed, ['ē']);
  });

  testWidgets('letras mostram o resultado do acento escolhido', (tester) async {
    await pumpGrid(tester);
    expect(find.text('á'), findsNothing);
    await tap(tester, 'tone-0');
    expect(find.text('á'), findsOneWidget);
  });

  testWidgets('combinante enviado inteiro', (tester) async {
    await pumpGrid(tester);
    await tap(tester, 'tone-4');
    await tap(tester, 'letter-4');
    expect(typer.typed, ['o̍͘']);
  });

  testWidgets('nasal ignora o acento e o desmarca', (tester) async {
    await pumpGrid(tester);
    await tap(tester, 'tone-0');
    await tap(tester, 'nasal');
    await tap(tester, 'letter-0');
    expect(typer.typed, ['ⁿ', 'a']);
  });

  testWidgets('shift físico mostra e digita maiúscula', (tester) async {
    await pumpGrid(tester);
    keys.shift = true;
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('A'), findsOneWidget);
    await tap(tester, 'tone-4');
    await tap(tester, 'letter-4');
    await tap(tester, 'nasal');
    expect(typer.typed, ['O̍͘', 'ᴺ']);

    keys.shift = false;
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('a'), findsOneWidget);
  });

  testWidgets('shift físico apertado logo antes do clique', (tester) async {
    await pumpGrid(tester);
    keys.shift = true; // sem esperar o polling
    await tap(tester, 'letter-0');
    expect(typer.typed, ['A']);
  });

  testWidgets('caps físico', (tester) async {
    await pumpGrid(tester);
    keys.caps = true;
    await tester.pump(const Duration(milliseconds: 40));
    await tap(tester, 'tone-1');
    await tap(tester, 'letter-7');
    expect(typer.typed, ['Ǹ']);
  });

  testWidgets('dica de tom no tooltip do acento', (tester) async {
    await pumpGrid(tester);
    final tip = tester.widget<Tooltip>(find.descendant(
        of: find.byKey(const Key('tone-4')), matching: find.byType(Tooltip)));
    expect(tip.message, startsWith('Tom 8'));
  });

  testWidgets('fallback quando digitar falha', (tester) async {
    await pumpGrid(tester, typeResult: false);
    await tap(tester, 'letter-0');
    expect(fallback, ['a']);
  });
}
