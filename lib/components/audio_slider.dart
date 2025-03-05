import 'package:flutter/material.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';

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
    return SliderTheme(
      data: SliderThemeData(
        inactiveTrackColor: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
        thumbShape:
            _isDragging ? null : RoundSliderThumbShape(enabledThumbRadius: 6),
        padding: EdgeInsets.all(0),
      ),
      child: SizedBox(
        height: 30,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Slider(
                  secondaryTrackValue: widget.value,
                  value: value,
                  min: widget.min,
                  max: widget.max,
                  onChanged: (val) {
                    setState(() {
                      value = val;
                    });
                  },
                  onChangeStart: (value) {
                    setState(() {
                      _isDragging = true;
                    });
                  },
                  onChangeEnd: (value) {
                    setState(() {
                      _isDragging = false;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                  },
                  // padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                if (_isDragging)
                  Positioned(
                    left: value / widget.max * constraints.maxWidth - 20,
                    top: -20,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fDurationHHMMSS(
                          Duration(seconds: value.toInt()),
                          short: true,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
