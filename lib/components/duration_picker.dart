import 'package:flutter/material.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';

class DurationPicker extends StatefulWidget {
  const DurationPicker({
    super.key,
    this.value,
    this.onChanged,
    this.quickOptionPressed,
  });

  final Duration? value;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? quickOptionPressed;
  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  int selectedHour = 0;
  int selectMinute = 0;
  final GlobalKey<NumberWheelState> _hourWheelKey = GlobalKey();
  final GlobalKey<NumberWheelState> _minuteWheelKey = GlobalKey();

  _handleValueChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(Duration(minutes: selectMinute, hours: selectedHour));
    }
  }

  @override
  void initState() {
    if (widget.value != null) {
      setState(() {
        selectedHour = widget.value!.inHours;
        selectMinute = widget.value!.inMinutes % 60;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Duration> quickOptions = {
      "15m": Duration(minutes: 15),
      "30m": Duration(minutes: 30),
      "60m": Duration(hours: 1),
      "2h": Duration(hours: 2),
      "3h": Duration(hours: 3),
      tr().off: Duration.zero,
    };

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 230,
      child: Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberWheel(
                  key: _hourWheelKey,
                  length: 24,
                  value: selectedHour,
                  onChanged:
                      (value) => setState(() {
                        selectedHour = value;
                        _handleValueChanged();
                      }),
                  trailing: 'H',
                ),
                SizedBox(width: 80),
                NumberWheel(
                  key: _minuteWheelKey,
                  length: 60,
                  value: selectMinute,
                  onChanged:
                      (value) => setState(() {
                        selectMinute = value;
                        _handleValueChanged();
                      }),
                  trailing: 'M',
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20),
            child: Wrap(
              direction: Axis.horizontal,
              verticalDirection: VerticalDirection.down,
              spacing: 16,
              runSpacing: 8,
              children: [
                for (var opt in quickOptions.keys)
                  SizedBox(
                    child: OutlinedButton(
                      onPressed: () {
                        int newHour = quickOptions[opt]!.inMinutes ~/ 60;
                        int newMinute = quickOptions[opt]!.inMinutes % 60;
                        _hourWheelKey.currentState!.jumpToIndex(newHour);
                        _minuteWheelKey.currentState!.jumpToIndex(newMinute);
                        if (widget.onChanged != null) {
                          widget.onChanged!(quickOptions[opt]!);
                        }

                        if (widget.quickOptionPressed != null) {
                          widget.quickOptionPressed!(quickOptions[opt]!);
                        }
                      },
                      child: Text(
                        opt,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NumberWheel extends StatefulWidget {
  const NumberWheel({
    super.key,
    required this.value,
    required this.length,
    required this.onChanged,
    this.trailing,
    this.fontSize = 24,
  });

  final int value;
  final int length;
  final ValueChanged<int>? onChanged;
  final String? trailing;
  final double fontSize;

  @override
  State<NumberWheel> createState() => NumberWheelState();
}

class NumberWheelState extends State<NumberWheel> {
  late FixedExtentScrollController _controller;

  bool disableScroll = false;

  scrollToIndex(int index) {
    disableScroll = true;
    _controller
        .animateToItem(
          index,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        )
        .then((_) {
          setState(() {
            disableScroll = false;
          });
          if (widget.onChanged != null) {
            widget.onChanged!(index);
          }
        });
  }

  jumpToIndex(int index) {
    _controller.jumpToItem(index);
    if (widget.onChanged != null) {
      widget.onChanged!(index);
    }
  }

  @override
  void initState() {
    _controller = FixedExtentScrollController(initialItem: widget.value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 80,
            width: 34,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 34,
              perspective: 0.01,
              magnification: 0.5,
              controller: _controller,
              physics: FixedExtentScrollPhysics(),

              onSelectedItemChanged: (index) {
                if (!disableScroll && widget.onChanged != null) {
                  widget.onChanged!(index);
                }
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  return Center(
                    child: Opacity(
                      opacity: index == widget.value ? 1 : 0.3,
                      child: Text(
                        index.toString().padLeft(
                          widget.length.toString().length,
                          '0',
                        ),
                        style: TextStyle(
                          fontSize:
                              index == widget.value
                                  ? widget.fontSize
                                  : widget.fontSize - 6,
                          height: 1,
                        ),
                      ),
                    ),
                  );
                },
                childCount: widget.length,
              ),
            ),
          ),
          if (widget.trailing != null)
            Text(
              widget.trailing!,
              style: TextStyle(fontSize: widget.fontSize, height: 1),
            ),
        ],
      ),
    );
  }
}
