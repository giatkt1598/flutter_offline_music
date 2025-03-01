import 'package:flutter/material.dart';

class AudioSlider extends StatefulWidget {
  final double value;

  final ValueChanged<double>? onChanged;
  final double min;
  final double max;

  const AudioSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
  });

  @override
  State<AudioSlider> createState() => _AudioSliderState();
}

class _AudioSliderState extends State<AudioSlider> {
  bool _isDragging = false;
  double value = 0;

  @override
  void didUpdateWidget(covariant AudioSlider oldWidget) {
    if (!_isDragging) {
      setState(() {
        value = widget.value;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        setState(() {
          _isDragging = true;
        });
      },
      onPointerUp: (e) {
        setState(() {
          _isDragging = false;
        });
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      child: SliderTheme(
        data: SliderThemeData(
          inactiveTrackColor: Theme.of(
            context,
          ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
          thumbShape:
              _isDragging ? null : RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        child: SizedBox(
          height: 30,
          child: Slider(
            value: value,
            min: widget.min,
            max: widget.max,
            onChanged: (val) {
              setState(() {
                value = val;
              });
            },
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
}
