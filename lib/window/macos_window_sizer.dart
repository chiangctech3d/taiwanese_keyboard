import 'package:flutter/services.dart';

import '../native/macos_channel.dart';
import 'window_sizer.dart';

class MacosWindowSizer implements WindowSizer {
  @override
  Future<void> setContentSize(Size size) async {
    try {
      await macosChannel.invokeMethod<void>('setContentSize', {
        'width': size.width,
        'height': size.height,
      });
    } on PlatformException {
      // Mantém o tamanho atual.
    } on MissingPluginException {
      // Mantém o tamanho atual.
    }
  }
}
