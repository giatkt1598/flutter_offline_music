import 'dart:async';

import 'package:flutter/material.dart';

class CountDownIcon extends StatefulWidget {
  const CountDownIcon({super.key, this.size = 24, this.endTime, this.onEnded});
  final double size;
  final DateTime? endTime;
  final Function? onEnded;
  @override
  State<CountDownIcon> createState() => _CountDownIconState();
}

class _CountDownIconState extends State<CountDownIcon> {
  Duration duration = Duration.zero;
  Timer? timer;
  calcDuration() {
    setState(() {
      duration = widget.endTime?.difference(DateTime.now()) ?? Duration.zero;

      if (duration < Duration.zero) {
        duration = Duration.zero;
      }
    });
  }

  @override
  void initState() {
    updateDuration();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CountDownIcon oldWidget) {
    if (widget.endTime != oldWidget.endTime) {
      updateDuration();
    }
    super.didUpdateWidget(oldWidget);
  }

  updateDuration() {
    calcDuration();
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!timer.isActive) return;
      calcDuration();
      if (duration == Duration.zero) {
        this.timer?.cancel();
        if (widget.onEnded != null) {
          widget.onEnded!();
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      // width: max(40, widget.size),
      child:
          duration == Duration.zero
              ? Icon(Icons.timer_sharp, size: widget.size)
              : Stack(
                clipBehavior: Clip.none,
                alignment: AlignmentDirectional.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, -widget.size / 2),
                    child: ClipRect(
                      child: Transform.translate(
                        offset: Offset(0, widget.size / 2),
                        child: Icon(Icons.timer_sharp, size: widget.size),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Transform.translate(
                      offset: Offset(0, -4),
                      child: Center(
                        child: Text(
                          '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 8, height: 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
