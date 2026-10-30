import 'dart:ui';

/// Muda o tamanho da área de conteúdo da janela do app.
abstract class WindowSizer {
  /// [size] em pixels lógicos.
  Future<void> setContentSize(Size size);
}
