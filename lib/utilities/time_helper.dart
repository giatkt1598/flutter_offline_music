String fDuration(Duration duration) {
  int minutes = duration.inMinutes;
  if (minutes < 60) return '$minutes phút';
  int hours = minutes ~/ 60;
  minutes = minutes % 60;
  return '$hours giờ $minutes phút';
}
