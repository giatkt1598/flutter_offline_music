import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/utilities/image_helper.dart';

class BlurImageWidget extends StatelessWidget {
  final String imagePath;
  final Size size;
  final double sigmaX;
  final double sigmaY;
  const BlurImageWidget({
    super.key,
    required this.imagePath,
    required this.size,
    this.sigmaX = 8,
    this.sigmaY = 8,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: loadUIImage(imagePath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        return CustomPaint(
          key: ValueKey(snapshot.data!),
          size: size,
          painter: BlurImagePainter(
            snapshot.data!,
            sigmaX: sigmaX,
            sigmaY: sigmaY,
          ),
        );
      },
    );
  }
}

class BlurImagePainter extends CustomPainter {
  final ui.Image image;
  final double sigmaX;
  final double sigmaY;

  BlurImagePainter(this.image, {required this.sigmaX, required this.sigmaY});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: sigmaX,
            sigmaY: sigmaY,
            tileMode: TileMode.mirror,
          );
    // Tính toán kích thước cắt ảnh theo BoxFit.cover
    Rect srcRect = calculateSrcRectToCover(image, size);
    Rect dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Vẽ ảnh bị blur
    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
