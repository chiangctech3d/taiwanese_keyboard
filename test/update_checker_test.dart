import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:teclado_taiwanes/update/update_checker.dart';

void main() {
  group('isNewer', () {
    test('compara número a número', () {
      expect(isNewer('0.2.0', than: '0.1.0'), true);
      expect(isNewer('0.10.0', than: '0.9.0'), true);
      expect(isNewer('1.0.0', than: '0.9.9'), true);
      expect(isNewer('0.2.0', than: '0.2.0'), false);
      expect(isNewer('0.1.0', than: '0.2.0'), false);
    });

    test('ignora o v e o sufixo de build', () {
      expect(isNewer('v0.2.1', than: '0.2.0+1'), true);
      expect(isNewer('v0.2.0', than: '0.2.0'), false);
    });
  });

  UpdateChecker checker(int status, Object body) => UpdateChecker(
    currentVersion: '0.2.0',
    client: MockClient(
      (_) async => http.Response(
        body is String ? body : jsonEncode(body),
        status,
        headers: {'content-type': 'application/json'},
      ),
    ),
  );

  test('versão nova disponível', () async {
    final r = await checker(200, {
      'tag_name': 'v0.3.0',
      'html_url': 'https://github.com/x/y/releases/tag/v0.3.0',
    }).check();
    expect(r, isA<UpdateAvailable>());
    expect((r as UpdateAvailable).version, '0.3.0');
    expect(r.url, 'https://github.com/x/y/releases/tag/v0.3.0');
  });

  test('já está na última', () async {
    expect(
      await checker(200, {'tag_name': 'v0.2.0', 'html_url': 'u'}).check(),
      isA<UpToDate>(),
    );
  });

  test('erro de rede ou resposta inválida', () async {
    expect(await checker(500, 'oops').check(), isA<UpdateCheckFailed>());
    expect(await checker(200, 'not json').check(), isA<UpdateCheckFailed>());
    final offline = UpdateChecker(
      currentVersion: '0.2.0',
      client: MockClient((_) async => throw http.ClientException('x')),
    );
    expect(await offline.check(), isA<UpdateCheckFailed>());
  });
}
