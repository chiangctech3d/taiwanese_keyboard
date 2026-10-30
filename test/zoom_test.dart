import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teclado_taiwanes/ui/app.dart';
import 'package:teclado_taiwanes/ui/zoom.dart';

import 'fakes/fakes.dart';

void main() {
  test('começa em 100% sem valor salvo', () async {
    SharedPreferences.setMockInitialValues({});
    final zoom = await ZoomController.load();
    expect(zoom.value, 1.0);
  });

  test('carrega o valor salvo', () async {
    SharedPreferences.setMockInitialValues({'zoom': 1.5});
    expect((await ZoomController.load()).value, 1.5);
  });

  test('valor salvo fora da escala vai para o passo mais próximo', () async {
    SharedPreferences.setMockInitialValues({'zoom': 1.3});
    expect((await ZoomController.load()).value, 1.25);
  });

  test('aumentar e diminuir seguem os passos e salvam', () async {
    SharedPreferences.setMockInitialValues({});
    final zoom = await ZoomController.load();
    await zoom.zoomIn();
    expect(zoom.value, 1.25);
    expect((await SharedPreferences.getInstance()).getDouble('zoom'), 1.25);
    await zoom.zoomOut();
    await zoom.zoomOut();
    expect(zoom.value, 0.8);
  });

  test('para nos limites', () async {
    SharedPreferences.setMockInitialValues({'zoom': 2.0});
    final zoom = await ZoomController.load();
    expect(zoom.canZoomIn, false);
    await zoom.zoomIn();
    expect(zoom.value, 2.0);
    expect(zoom.canZoomOut, true);
  });

  testWidgets('botão A+ redimensiona a janela', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final zoom = await ZoomController.load();
    final sizer = FakeWindowSizer();
    await tester.pumpWidget(TecladoApp(
      typer: FakeTyper(),
      keyboardState: FakeKeyboardState(),
      isMac: false,
      zoom: zoom,
      windowSizer: sizer,
    ));
    await tester.tap(find.byKey(const Key('zoom-in')));
    await tester.pumpAndSettle();
    expect(sizer.sizes.last, baseContentSize * 1.25);
    await tester.tap(find.byKey(const Key('zoom-out')));
    await tester.pumpAndSettle();
    expect(sizer.sizes.last, baseContentSize);
  });
}
