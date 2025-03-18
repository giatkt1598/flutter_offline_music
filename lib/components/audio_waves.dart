import 'dart:math';

import 'package:flutter/material.dart';

class AudioWaves extends StatefulWidget {
  const AudioWaves({
    super.key,
    this.playing = true,
    this.waveCount = 60,
    this.height = 50,
  });
  final bool playing;
  final int waveCount;
  final double height;
  @override
  State<AudioWaves> createState() => _AudioWavesState();
}

class _AudioWavesState extends State<AudioWaves> with TickerProviderStateMixin {
  int get waveCount => widget.waveCount; // Số lượng wave
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<double> _waveHeights;

  @override
  void initState() {
    super.initState();
    _waveHeights = List.generate(waveCount, (index) => _randomHeight(index));

    _controllers = List.generate(
      waveCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 500 + Random().nextInt(500),
        ), // Thời gian dao động khác nhau
      ),
    );

    _animations = List.generate(waveCount, (index) {
      return Tween<double>(
        begin: _waveHeights[index],
        end: _randomHeight(index),
      ).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeInOut, // Hiệu ứng mượt
        ),
      )..addListener(() {
        setState(() {});
      });
    });

    if (widget.playing) {
      _startWaveAnimations();
    }
  }

  void _startWaveAnimations() {
    for (int i = 0; i < waveCount; i++) {
      _animateWave(i);
    }
  }

  void _pauseWaveAnimations() {
    for (int i = 0; i < waveCount; i++) {
      _controllers[i].stop();
    }
  }

  @override
  void didUpdateWidget(covariant AudioWaves oldWidget) {
    if (oldWidget.playing != widget.playing) {
      if (widget.playing) {
        _startWaveAnimations();
      } else {
        _pauseWaveAnimations();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  double _randomHeight(int index) {
    double randVal =
        0.2 + Random().nextDouble() * 0.8; // Giá trị từ 0.3 đến 1.0
    double wavePosition = index / (waveCount - 1) + 0.5; // Vị trí từ 0 → 1
    double envelope = 0.5 * (1 - cos(pi * wavePosition)); // Làm nhỏ 2 đầu
    double randomFactor = randVal; // Random height nhưng không nhảy loạn
    return envelope * randomFactor; // Kết hợp envelope để giữ mép nhỏ dần
  }

  void _animateWave(int index) {
    double newHeight = _randomHeight(index);
    _animations[index] = Tween<double>(
      begin: _animations[index].value,
      end: newHeight,
    ).animate(
      CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOut),
    )..addListener(() {
      setState(() {});
    });

    _controllers[index]
      ..reset()
      ..forward().whenComplete(() => _animateWave(index)); // Lặp lại hiệu ứng
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveformPainter(_animations.map((a) => a.value).toList(), 0),
      child: Container(height: widget.height),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> samples;
  final double progress;
  final double spacing = 3.0; // Khoảng cách giữa các wave
  final double borderRadius = 999.0; // Bo tròn đầu wave

  WaveformPainter(this.samples, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.red, Colors.purple, Colors.blue],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final double barWidth = (size.width / samples.length) - spacing;
    for (int i = 0; i < samples.length; i++) {
      final double height = samples[i] * size.height;
      final double x = i * (barWidth + spacing);
      final RRect waveRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, (size.height - height) / 2, barWidth, height),
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(waveRect, paint);
    }

    // Vẽ thanh trượt (progress bar)
    // final Paint progressPaint = Paint()..color = Colors.white.withOpacity(0.8);
    // double progressX = progress * size.width;
    // canvas.drawRect(
    //   Rect.fromLTWH(progressX - 2, 0, 4, size.height),
    //   progressPaint,
    // );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => true;
}
