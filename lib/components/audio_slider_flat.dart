import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider.dart';

class AudioSliderFlat extends StatefulWidget {
  final double value;

  final ValueChanged<double>? onChanged;
  final double min;
  final double max;

  const AudioSliderFlat({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
  });

  @override
  State<AudioSliderFlat> createState() => _AudioSliderFlatState();
}

class _AudioSliderFlatState extends State<AudioSliderFlat> {
  late InteractiveSliderController _controller;
  bool _isDragging = false;
  double value = 0;

  @override
  void initState() {
    super.initState();
    _controller = InteractiveSliderController(widget.value);
  }

  @override
  void didUpdateWidget(covariant AudioSliderFlat oldWidget) {
    if (!_isDragging) {
      setState(() {
        value = widget.value / widget.max;
        _controller.value = value;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Listener(
          onPointerDown: (event) {
            setState(() {
              _isDragging = true;
            });
          },
          onPointerUp: (event) {
            setState(() {
              _isDragging = false;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value * widget.max);
            }
          },
          child: Container(
            color: Colors.transparent,
            child: InteractiveSlider(
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  // _isDragging = true;
                  this.value = value;
                });
              },
              unfocusedOpacity: 1,
              unfocusedHeight: 4,
              focusedHeight: 8,
              gradient: LinearGradient(
                colors: [Colors.red, Colors.purple, Colors.blue],
              ),
              gradientSize: GradientSize.totalWidth,
            ),
          ),
        ),
      ],
    );
  }
}
