import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/app_setting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSetting', () {
    test('serializes and deserializes correctly', () {
      final setting = AppSetting(
        themeMode: ThemeMode.dark,
        skipSilent: true,
        autoVolumnPausePlay: false,
        autoScanFiles: true,
        languageCode: 'vi',
        playerBackgroundImage: 'assets/bg_music_1.png',
        backgroundBlurValue: 0.5,
        playerTheme: 'three',
        keepScreenOn: true,
      );

      final json = setting.toJson();
      final decoded = AppSetting.fromJson(json);

      expect(decoded.themeMode, ThemeMode.dark);
      expect(decoded.skipSilent, isTrue);
      expect(decoded.autoVolumnPausePlay, isFalse);
      expect(decoded.autoScanFiles, isTrue);
      expect(decoded.languageCode, 'vi');
      expect(decoded.playerBackgroundImage, 'assets/bg_music_1.png');
      expect(decoded.backgroundBlurValue, 0.5);
      expect(decoded.playerTheme, 'three');
      expect(decoded.keepScreenOn, isTrue);
    });
  });
}
