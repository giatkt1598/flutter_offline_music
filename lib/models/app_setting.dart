import 'package:flutter/material.dart';

class AppSetting {
  ThemeMode themeMode = ThemeMode.system;
  bool skipSilent = false;
  bool autoVolumnPausePlay = true;
  bool autoScanFiles = false;
  String languageCode = 'vi';
  String playerBackgroundImage = '';
  double backgroundBlurValue; // Value from 0 -> 1.0
  String playerTheme;

  AppSetting({
    this.themeMode = ThemeMode.system,
    this.skipSilent = false,
    this.autoVolumnPausePlay = true,
    this.autoScanFiles = false,
    this.languageCode = 'vi',
    this.playerBackgroundImage = '',
    this.backgroundBlurValue = 1.0,
    this.playerTheme = 'default',
  });

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'skipSilent': skipSilent,
      'autoVolumnPausePlay': autoVolumnPausePlay,
      'autoScanFiles': autoScanFiles,
      'languageCode': languageCode,
      'playerBackgroundImage': playerBackgroundImage,
      'backgroundBlurValue': backgroundBlurValue,
      'playerTheme': playerTheme,
    };
  }

  factory AppSetting.fromJson(Map<String, dynamic> json) {
    return AppSetting(
      themeMode: ThemeMode.values[json['themeMode']],
      skipSilent: json['skipSilent'],
      autoVolumnPausePlay: json['autoVolumnPausePlay'],
      autoScanFiles: json['autoScanFiles'],
      languageCode: json['languageCode'],
      playerBackgroundImage: json['playerBackgroundImage'],
      backgroundBlurValue: json['backgroundBlurValue'],
      playerTheme: json['playerTheme'],
    );
  }
}
