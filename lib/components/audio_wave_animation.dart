import 'package:flutter/material.dart';
import 'dart:math';

class AudioWaveAnimation extends StatefulWidget {
  const AudioWaveAnimation({super.key});

  @override
  State<AudioWaveAnimation> createState() => _AudioWaveAnimationState();
}

class _AudioWaveAnimationState extends State<AudioWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<double> waveValues = List.generate(5, (_) => 0.5); // Initial wave values

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 50000),
    )..addListener(() {
      setState(() {
        // Randomize wave heights to simulate audio frequency changes
        waveValues = List.generate(5, (_) => Random().nextDouble());
      });
    });

    _controller.repeat(reverse: true); // Loop animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 100),
      painter: AudioWavePainter(waveValues),
    );
  }
}

class AudioWavePainter extends CustomPainter {
  final List<double> waveValues;

  AudioWavePainter(this.waveValues);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.blueAccent
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;

    double barWidth = size.width / waveValues.length;
    double maxHeight = size.height;

    for (int i = 0; i < waveValues.length; i++) {
      double height = waveValues[i] * maxHeight; // Scale wave height
      double x = i * barWidth + barWidth / 2;
      canvas.drawLine(
        Offset(x, maxHeight / 2 - height / 2),
        Offset(x, maxHeight / 2 + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
