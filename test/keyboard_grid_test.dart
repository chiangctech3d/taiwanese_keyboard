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

  Future<void> tapKey(WidgetTester tester, Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pump();
  }

  // Espera passar a janela de duplo clique do Shift.
  Future<void> settleShift(WidgetTester tester) =>
      tester.pump(const Duration(milliseconds: 400));

  testWidgets('minúscula por padrão', (tester) async {
    await pumpGrid(tester);
    await tapKey(tester, const Key('k-0-0'));
    expect(typer.typed, ['á']);
  });

  testWidgets('shift único reseta', (tester) async {
    await pumpGrid(tester);
    await tapKey(tester, const Key('shift'));
    await settleShift(tester);
    await tapKey(tester, const Key('k-0-0'));
    await tapKey(tester, const Key('k-0-0'));
    expect(typer.typed, ['Á', 'á']);
  });

  testWidgets('shift travado com duplo clique', (tester) async {
    await pumpGrid(tester);
    await tapKey(tester, const Key('shift'));
    await tester.pump(const Duration(milliseconds: 100));
    await tapKey(tester, const Key('shift'));
    await settleShift(tester);
    await tapKey(tester, const Key('k-0-0'));
    await tapKey(tester, const Key('k-0-0'));
    expect(typer.typed, ['Á', 'Á']);

    // Mais um clique destrava.
    await tapKey(tester, const Key('shift'));
    await settleShift(tester);
    await tapKey(tester, const Key('k-0-0'));
    expect(typer.typed.last, 'á');
  });

  testWidgets('shift físico mostra e digita maiúscula', (tester) async {
    await pumpGrid(tester);
    keys.shift = true;
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('Á'), findsOneWidget);
    await tapKey(tester, const Key('k-0-0'));
    expect(typer.typed, ['Á']);

    keys.shift = false;
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('á'), findsOneWidget);
  });

  testWidgets('caps físico', (tester) async {
    await pumpGrid(tester);
    keys.caps = true;
    await tester.pump(const Duration(milliseconds: 40));
    await tapKey(tester, const Key('nasal'));
    await tapKey(tester, const Key('oh'));
    expect(typer.typed, ['ᴺ', 'O͘']);
  });

  testWidgets('shift único reseta mesmo com caps físico ligado depois',
      (tester) async {
    await pumpGrid(tester);
    await tapKey(tester, const Key('shift'));
    await settleShift(tester);
    await tapKey(tester, const Key('k-0-0'));
    keys.caps = true;
    await tester.pump(const Duration(milliseconds: 40));
    await tapKey(tester, const Key('k-0-0'));
    keys.caps = false;
    await tester.pump(const Duration(milliseconds: 40));
    await tapKey(tester, const Key('k-0-0'));
    expect(typer.typed, ['Á', 'Á', 'á']);
  });

  testWidgets('combinante enviado inteiro', (tester) async {
    await pumpGrid(tester);
    await tapKey(tester, const Key('k-4-4'));
    expect(typer.typed, ['o̍͘']);
  });

  testWidgets('fallback quando digitar falha', (tester) async {
    await pumpGrid(tester, typeResult: false);
    await tapKey(tester, const Key('k-0-0'));
    expect(fallback, ['á']);
  });

  testWidgets('shift físico apertado logo antes do clique', (tester) async {
    await pumpGrid(tester);
    keys.shift = true; // sem esperar o polling
    await tapKey(tester, const Key('k-0-0'));
    expect(typer.typed, ['Á']);
  });

  testWidgets('botão Shift mostra o estado de cada fonte', (tester) async {
    await pumpGrid(tester);
    expect(find.text('Shift'), findsOneWidget);

    keys.shift = true;
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('Shift físico'), findsOneWidget);
    keys.shift = false;
    await tester.pump(const Duration(milliseconds: 40));

    await tapKey(tester, const Key('shift'));
    await tester.pump(const Duration(milliseconds: 100));
    await tapKey(tester, const Key('shift'));
    await settleShift(tester);
    expect(find.text('Shift fixo'), findsOneWidget);
  });

  testWidgets('dica de tom no tooltip', (tester) async {
    await pumpGrid(tester);
    final tip = tester.widget<Tooltip>(find.descendant(
        of: find.byKey(const Key('k-0-4')), matching: find.byType(Tooltip)));
    expect(tip.message, startsWith('Tom 8'));
  });
}
