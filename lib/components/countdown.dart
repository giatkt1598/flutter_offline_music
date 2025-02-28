import 'dart:async';

import 'package:flutter/cupertino.dart';

class Countdown extends StatefulWidget {
  const Countdown({super.key, this.endTime, this.onEnded});

  final DateTime? endTime;
  final Function? onEnded;
  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
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
  void didUpdateWidget(covariant Countdown oldWidget) {
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
    final txt =
        duration > Duration(minutes: 5)
            ? '${duration.inHours} giờ ${duration.inMinutes % 60} phút'
            : '${duration.inMinutes} phút ${duration.inSeconds % 60} giây';
    return Text(txt);
  }
}
