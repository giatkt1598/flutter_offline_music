import 'package:flutter/material.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';

bool isDarkMode() {
  return Theme.of(SharedData.rootContext).brightness == Brightness.dark;
}
