import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tamanho do teclado em 100%, com o rodapé (versão e atualizações).
const Size baseContentSize = Size(448, 130);

/// Passos de A− / A+.
const List<double> zoomSteps = [0.8, 1.0, 1.25, 1.5, 1.75, 2.0];

const _prefsKey = 'zoom';

/// Tamanho do teclado escolhido pelo usuário, salvo entre execuções.
class ZoomController extends ValueNotifier<double> {
  ZoomController._(this._prefs, super.value);

  final SharedPreferences _prefs;

  static Future<ZoomController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_prefsKey) ?? 1.0;
    final nearest = zoomSteps.reduce(
      (a, b) => (a - saved).abs() <= (b - saved).abs() ? a : b,
    );
    return ZoomController._(prefs, nearest);
  }

  int get _index => zoomSteps.indexOf(value);
  bool get canZoomIn => _index < zoomSteps.length - 1;
  bool get canZoomOut => _index > 0;

  Size get contentSize => baseContentSize * value;

  Future<void> zoomIn() => _set(canZoomIn ? zoomSteps[_index + 1] : value);
  Future<void> zoomOut() => _set(canZoomOut ? zoomSteps[_index - 1] : value);

  Future<void> _set(double v) async {
    if (v == value) return;
    value = v;
    await _prefs.setDouble(_prefsKey, v);
  }
}
