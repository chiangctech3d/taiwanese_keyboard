import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teclado_taiwanes/ui/update_bar.dart';
import 'package:teclado_taiwanes/update/update_checker.dart';

void main() {
  Widget bar(
    Future<UpdateResult> Function() check, {
    List<String>? opened,
    bool auto = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: UpdateBar(
          version: '0.2.0',
          check: check,
          openUrl: (u) async => opened?.add(u),
          checkOnStart: auto,
        ),
      ),
    );
  }

  testWidgets('mostra a versão e o botão em repouso', (tester) async {
    await tester.pumpWidget(bar(() async => const UpToDate()));
    expect(find.text('v0.2.0'), findsOneWidget);
    expect(find.text('Verificar atualizações'), findsOneWidget);
  });

  testWidgets('já atualizado', (tester) async {
    await tester.pumpWidget(bar(() async => const UpToDate()));
    await tester.tap(find.byKey(const Key('update')));
    await tester.pumpAndSettle();
    expect(find.text('Você está na última versão'), findsOneWidget);
  });

  testWidgets('nova versão: botão abre a página', (tester) async {
    final opened = <String>[];
    await tester.pumpWidget(
      bar(
        () async => const UpdateAvailable(version: '0.3.0', url: 'https://x'),
        opened: opened,
      ),
    );
    await tester.tap(find.byKey(const Key('update')));
    await tester.pumpAndSettle();
    expect(find.text('Baixar versão 0.3.0'), findsOneWidget);
    await tester.tap(find.byKey(const Key('update')));
    expect(opened, ['https://x']);
  });

  testWidgets('falha', (tester) async {
    await tester.pumpWidget(bar(() async => const UpdateCheckFailed()));
    await tester.tap(find.byKey(const Key('update')));
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível verificar'), findsOneWidget);
  });

  testWidgets('verifica ao abrir quando pedido', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      bar(() async {
        calls++;
        return const UpdateAvailable(version: '0.3.0', url: 'u');
      }, auto: true),
    );
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('Baixar versão 0.3.0'), findsOneWidget);
  });

  testWidgets('não verifica ao abrir por padrão', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      bar(() async {
        calls++;
        return const UpToDate();
      }),
    );
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets('mostra "Verificando…" enquanto espera', (tester) async {
    final c = Completer<UpdateResult>();
    await tester.pumpWidget(bar(() => c.future));
    await tester.tap(find.byKey(const Key('update')));
    await tester.pump();
    expect(find.text('Verificando…'), findsOneWidget);
    c.complete(const UpToDate());
    await tester.pumpAndSettle();
  });
}
