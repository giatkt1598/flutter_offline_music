import 'package:flutter/foundation.dart';

void logDebug(dynamic object) {
  if (!kDebugMode) {
    return;
  }
  String message = object != null ? object.toString() : 'null';
  // ignore: avoid_print
  print('[Debug]${DateTime.now()}: $message');
}
