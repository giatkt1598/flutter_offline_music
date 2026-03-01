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
  int get waveCount => widget.waveCount;
  final Random _random = Random();

  late List<AnimationController> _controllers;
  late List<CurvedAnimation> _curves;
  late List<Tween<double>> _tweens;
  int _animationRunId = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (widget.playing) {
      _startWaveAnimations();
    }
  }

  void _initAnimations() {
    _controllers = List.generate(
      waveCount,
      (_) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + _random.nextInt(500)),
      ),
    );

    _curves = List.generate(
      waveCount,
      (index) =>
          CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOut),
    );

    _tweens = List.generate(waveCount, (index) {
      final double initialHeight = _randomHeight(index);
      return Tween<double>(begin: initialHeight, end: _randomHeight(index));
    });
  }

  void _disposeAnimations() {
    for (final curve in _curves) {
      curve.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
  }

  void _startWaveAnimations() {
    _animationRunId++;
    final int runId = _animationRunId;

    for (int i = 0; i < waveCount; i++) {
      _animateWave(i, runId);
    }
  }

  void _pauseWaveAnimations() {
    _animationRunId++;
    for (int i = 0; i < waveCount; i++) {
      _controllers[i].stop();
    }
  }

  @override
  void didUpdateWidget(covariant AudioWaves oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.waveCount != widget.waveCount) {
      _pauseWaveAnimations();
      _disposeAnimations();
      _initAnimations();

      if (widget.playing) {
        _startWaveAnimations();
      }
      return;
    }

    if (oldWidget.playing != widget.playing) {
      if (widget.playing) {
        _startWaveAnimations();
      } else {
        _pauseWaveAnimations();
      }
    }
  }

  double _randomHeight(int index) {
    final double randVal = 0.2 + _random.nextDouble() * 0.8;
    final int denominator = max(waveCount - 1, 1);
    final double wavePosition = index / denominator + 0.5;
    final double envelope = 0.5 * (1 - cos(pi * wavePosition));
    return envelope * randVal;
  }

  double _currentHeight(int index) {
    return _tweens[index].transform(_curves[index].value);
  }

  void _animateWave(int index, int runId) {
    if (!mounted || !widget.playing || runId != _animationRunId) {
      return;
    }

    _tweens[index] = Tween<double>(
      begin: _currentHeight(index),
      end: _randomHeight(index),
    );
    _controllers[index]
      ..reset()
      ..forward().whenComplete(() {
        if (!mounted || !widget.playing || runId != _animationRunId) {
          return;
        }
        _animateWave(index, runId);
      });
  }

  @override
  void dispose() {
    _pauseWaveAnimations();
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveformPainter(curves: _curves, tweens: _tweens),
      child: SizedBox(width: double.infinity, height: widget.height),
    );
  }
}

class WaveformPainter extends CustomPainter {
  WaveformPainter({
    required this.curves,
    required this.tweens,
    this.progress = 0,
  }) : super(repaint: Listenable.merge(curves));

  final List<CurvedAnimation> curves;
  final List<Tween<double>> tweens;
  final double progress;
  final double spacing = 3.0; // Khoảng cách giữa các wave
  final double borderRadius = 999.0; // Bo tròn đầu wave

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..shader = const LinearGradient(
            colors: [Colors.red, Colors.purple, Colors.blue],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final int sampleCount = min(curves.length, tweens.length);
    if (sampleCount == 0) {
      return;
    }

    final double barWidth = max(
      (size.width - spacing * (sampleCount - 1)) / sampleCount,
      0.5,
    );
    for (int i = 0; i < sampleCount; i++) {
      final double height = tweens[i].transform(curves[i].value) * size.height;
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
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.curves != curves ||
        oldDelegate.tweens != tweens ||
        oldDelegate.progress != progress;
  }
}
