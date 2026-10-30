import 'dart:convert';

import 'package:http/http.dart' as http;

/// Página de releases do projeto; abre no navegador quando há versão nova.
const releasesUrl =
    'https://github.com/chiangctech3d/taiwanese_keyboard/releases';

const _latestApi =
    'https://api.github.com/repos/chiangctech3d/taiwanese_keyboard/releases/latest';

sealed class UpdateResult {
  const UpdateResult();
}

class UpToDate extends UpdateResult {
  const UpToDate();
}

class UpdateAvailable extends UpdateResult {
  const UpdateAvailable({required this.version, required this.url});

  final String version;
  final String url;
}

class UpdateCheckFailed extends UpdateResult {
  const UpdateCheckFailed();
}

/// `true` se [version] é mais nova que [than]. Aceita `v` na frente e
/// ignora o sufixo de build (`0.2.0+1`).
bool isNewer(String version, {required String than}) {
  final a = _parse(version);
  final b = _parse(than);
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] > b[i];
  }
  return false;
}

List<int> _parse(String v) {
  final core = v.replaceFirst(RegExp(r'^v'), '').split('+').first;
  final parts = core.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  while (parts.length < 3) {
    parts.add(0);
  }
  return parts;
}

/// Consulta a última release no GitHub e compara com a versão instalada.
class UpdateChecker {
  UpdateChecker({required this.currentVersion, http.Client? client})
    : _client = client ?? http.Client();

  final String currentVersion;
  final http.Client _client;

  Future<UpdateResult> check() async {
    try {
      final response = await _client
          .get(
            Uri.parse(_latestApi),
            headers: {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'teclado-taiwanes/$currentVersion',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return const UpdateCheckFailed();
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final tag = json['tag_name'] as String;
      final url = json['html_url'] as String? ?? releasesUrl;
      final version = tag.replaceFirst(RegExp(r'^v'), '');
      return isNewer(version, than: currentVersion)
          ? UpdateAvailable(version: version, url: url)
          : const UpToDate();
    } catch (_) {
      return const UpdateCheckFailed();
    }
  }
}
