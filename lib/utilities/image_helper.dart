// Load image from file and convert it to `ui.Image`
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

Future<ui.Image> loadUIImage(String path) async {
  final Completer<ui.Image> completer = Completer();

  if (path.startsWith('assets/')) {
    // Load image as ByteData
    final ByteData data = await rootBundle.load(path);

    // Convert ByteData to Uint8List
    final Uint8List bytes = data.buffer.asUint8List();

    ui.decodeImageFromList(bytes, (ui.Image img) => completer.complete(img));
    return completer.future;
  }

  final File imageFile = File(path);
  final Uint8List imageBytes = await imageFile.readAsBytes();
  ui.decodeImageFromList(imageBytes, (ui.Image img) => completer.complete(img));
  return completer.future;
}
