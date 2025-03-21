import 'package:flutter_offline_music/i18n/i18n.dart';

String fDurationLong(Duration duration) {
  int minutes = duration.inMinutes;
  if (minutes < 60) return tr().nMinutes(minutes);
  int hours = minutes ~/ 60;
  minutes = minutes % 60;
  return '${hours > 0 ? tr().nHours(hours) : ''} ${minutes > 0 ? tr().nMinutes(minutes) : ''}'
      .trim();
}

String fDurationHHMMSS(Duration duration, {bool? short = false}) {
  int seconds = duration.inSeconds % 60;
  int minutes = duration.inMinutes % 60;
  int hours = duration.inHours;

  return [
    short == true && hours == 0 ? null : hours,
    minutes,
    seconds,
  ].where((x) => x != null).map((x) => x.toString().padLeft(2, '0')).join(':');
}
