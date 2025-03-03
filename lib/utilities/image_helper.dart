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

/// Hàm tính toán vùng cắt ảnh để đảm bảo `BoxFit.cover`
Rect calculateSrcRectToCover(ui.Image image, Size targetSize) {
  double imageAspect = image.width / image.height;
  double targetAspect = targetSize.width / targetSize.height;

  double srcWidth, srcHeight;
  if (imageAspect > targetAspect) {
    // Ảnh rộng hơn => Cắt chiều ngang
    srcHeight = image.height.toDouble();
    srcWidth = srcHeight * targetAspect;
  } else {
    // Ảnh cao hơn => Cắt chiều dọc
    srcWidth = image.width.toDouble();
    srcHeight = srcWidth / targetAspect;
  }

  double srcX = (image.width - srcWidth) / 2;
  double srcY = (image.height - srcHeight) / 2;

  return Rect.fromLTWH(srcX, srcY, srcWidth, srcHeight);
}
