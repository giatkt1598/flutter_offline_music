import 'package:flutter/material.dart';

class AppSetting {
  ThemeMode themeMode = ThemeMode.system;
  bool skipSilent = false;
  bool autoVolumnPausePlay = true;
  bool useHeadsetControl = true;
  bool autoScanFiles = false;
  bool pauseWhenOpenOtherApp = true;
  String languageCode = 'vi';

  AppSetting({
    this.themeMode = ThemeMode.system,
    this.skipSilent = false,
    this.autoVolumnPausePlay = true,
    this.useHeadsetControl = true,
    this.autoScanFiles = false,
    this.pauseWhenOpenOtherApp = true,
    this.languageCode = 'vi',
  });

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'skipSilent': skipSilent,
      'autoVolumnPausePlay': autoVolumnPausePlay,
      'useHeadsetControl': useHeadsetControl,
      'autoScanFiles': autoScanFiles,
      'pauseWhenOpenOtherApp': pauseWhenOpenOtherApp,
      'languageCode': languageCode,
    };
  }

  factory AppSetting.fromJson(Map<String, dynamic> json) {
    return AppSetting(
      themeMode: ThemeMode.values[json['themeMode']],
      skipSilent: json['skipSilent'],
      autoVolumnPausePlay: json['autoVolumnPausePlay'],
      useHeadsetControl: json['useHeadsetControl'],
      autoScanFiles: json['autoScanFiles'],
      pauseWhenOpenOtherApp: json['pauseWhenOpenOtherApp'],
      languageCode: json['languageCode'],
    );
  }
}
