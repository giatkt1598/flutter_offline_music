import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/utilities/image_helper.dart';
import 'package:provider/provider.dart';

class RotatingImageDisc extends StatefulWidget {
  const RotatingImageDisc({super.key, required this.backgroundImageUrl});

  final String backgroundImageUrl;

  @override
  State<RotatingImageDisc> createState() => _RotatingImageDiscState();
}

class _RotatingImageDiscState extends State<RotatingImageDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void play() {
    _controller.repeat();
  }

  void stop() {
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = Provider.of<PlayerProvider>(context).audioHandler.playing;
    if (isPlaying) {
      play();
    } else {
      stop();
    }

    double size =
        min(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        ) *
        0.85;

    size = min(size, 400);
    return RotationTransition(
      turns: _controller,
      child: FutureBuilder<ui.Image>(
        future: loadUIImage(widget.backgroundImageUrl),
        builder: (context, snapshot) {
          if (snapshot.data == null) return Container();
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CustomPaint(
                        size: Size(size, size),
                        painter: CircleTransparentPainter(snapshot.data!),
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/disc_hole.png',
                    width: constraints.maxWidth * 0.4,
                    height: constraints.maxWidth * 0.4,
                    fit: BoxFit.cover,
                  ),
                  // 🔹 Overlay with Circular Transparent Cutout
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class CircleTransparentPainter extends CustomPainter {
  final ui.Image image;

  CircleTransparentPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Draw image on a new layer
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.saveLayer(rect, Paint()); // ✅ Save layer before clearing pixels
    // Vẽ ảnh
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      ), // Ảnh gốc
      Rect.fromLTWH(0, 0, size.width, size.height), // Ảnh được vẽ trên canvas
      paint,
    );

    // Tạo vùng trong suốt hình tròn
    Paint transparentPaint =
        Paint()..blendMode = BlendMode.clear; // Xóa vùng này khỏi ảnh

    canvas.drawCircle(
      size.center(Offset.zero), // Vị trí trung tâm
      40, // Bán kính của hình tròn
      transparentPaint,
    );

    canvas.restore(); // ✅ Restore layer after drawing
  }

  @override
  bool shouldRepaint(CircleTransparentPainter oldDelegate) => false;
}
