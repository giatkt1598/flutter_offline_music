import 'dart:io';

import 'package:flutter/material.dart';

class RotatingCircleImage extends StatefulWidget {
  const RotatingCircleImage({
    super.key,
    required this.bgImage,
    required this.isRotate,
  });

  final String bgImage;
  final bool isRotate;

  @override
  State<RotatingCircleImage> createState() => _RotatingCircleImageState();
}

class _RotatingCircleImageState extends State<RotatingCircleImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    updatePlaying();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void updatePlaying() {
    if (widget.isRotate) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void didUpdateWidget(covariant RotatingCircleImage oldWidget) {
    if (oldWidget.isRotate != widget.isRotate) {
      updatePlaying();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.5,
        height: MediaQuery.sizeOf(context).width * 0.5,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2, color: Colors.white30),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 10,
                spreadRadius: -2,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.file(File(widget.bgImage), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
