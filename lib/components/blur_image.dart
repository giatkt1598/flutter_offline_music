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
    Rect srcRect = _calculateSrcRect(image, size);
    Rect dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Vẽ ảnh bị blur
    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  /// Hàm tính toán vùng cắt ảnh để đảm bảo `BoxFit.cover`
  Rect _calculateSrcRect(ui.Image image, Size targetSize) {
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
