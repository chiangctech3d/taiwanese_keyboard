import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teclado_taiwanes/native/macos_channel.dart';
import 'package:teclado_taiwanes/typing/macos_typer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('erro do canal vira false (aciona o fallback)', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(macosChannel, (call) async {
      throw PlatformException(code: 'x');
    });
    expect(await MacosTyper().type('á'), false);
  });

  test('canal ausente vira false', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(macosChannel, null);
    expect(await MacosTyper().type('á'), false);
  });
}
