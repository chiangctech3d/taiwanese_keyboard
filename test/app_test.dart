import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teclado_taiwanes/ui/app.dart';

import 'fakes/fakes.dart';

void main() {
  late List<String?> clipboard;

  setUp(() {
    clipboard = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard.add((call.arguments as Map)['text'] as String?);
      }
      return null;
    });
  });

  testWidgets('fallback copia e mostra aviso (Windows)', (tester) async {
    await tester.pumpWidget(TecladoApp(
      typer: FakeTyper(result: false),
      keyboardState: FakeKeyboardState(),
      isMac: false,
    ));
    await tester.tap(find.byKey(const Key('letter-0')));
    await tester.pumpAndSettle();
    expect(clipboard, ['a']);
    expect(find.text('Copiado — cole com Ctrl+V'), findsOneWidget);
  });

  testWidgets('fallback no Mac oferece Permitir', (tester) async {
    var opened = 0;
    await tester.pumpWidget(TecladoApp(
      typer: FakeTyper(result: false),
      keyboardState: FakeKeyboardState(),
      isMac: true,
      onOpenSettings: () async => opened++,
    ));
    await tester.tap(find.byKey(const Key('letter-0')));
    await tester.pumpAndSettle();
    expect(find.text('Copiado — cole com ⌘V'), findsOneWidget);
    await tester.tap(find.text('Permitir'));
    expect(opened, 1);
  });

  testWidgets('sucesso não mostra aviso', (tester) async {
    await tester.pumpWidget(TecladoApp(
      typer: FakeTyper(),
      keyboardState: FakeKeyboardState(),
      isMac: false,
    ));
    await tester.tap(find.byKey(const Key('letter-0')));
    await tester.pumpAndSettle();
    expect(clipboard, isEmpty);
    expect(find.byType(SnackBar), findsNothing);
  });
}
