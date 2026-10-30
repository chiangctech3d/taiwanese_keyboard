import 'package:flutter/services.dart';

Future<void> copyFallback(String text) =>
    Clipboard.setData(ClipboardData(text: text));
