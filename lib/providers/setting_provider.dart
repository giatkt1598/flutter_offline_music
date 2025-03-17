import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/app_setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider extends ChangeNotifier {
  static AppSetting _appSetting = AppSetting();
  AppSetting get appSetting => _appSetting;
  static AppSetting get staticAppSetting => _appSetting;

  SettingProvider({ThemeMode? initialThemeMode}) {
    _appSetting.themeMode = initialThemeMode ?? _appSetting.themeMode;
    loadSetting();
  }

  Future<void> setting({
    ThemeMode? themeMode,
    bool? skipSilent,
    bool? autoVolumnPausePlay,
    bool? autoScanFiles,
    bool? pauseWhenOpenOtherApp,
    String? languageCode,
    String? playerBackgroundImage,
    double? backgroundBlurValue,
    String? playerTheme,
  }) async {
    _appSetting.autoScanFiles = autoScanFiles ?? _appSetting.autoScanFiles;
    _appSetting.autoVolumnPausePlay =
        autoVolumnPausePlay ?? _appSetting.autoVolumnPausePlay;
    _appSetting.languageCode = languageCode ?? _appSetting.languageCode;
    _appSetting.skipSilent = skipSilent ?? _appSetting.skipSilent;
    _appSetting.themeMode = themeMode ?? _appSetting.themeMode;
    _appSetting.playerBackgroundImage =
        playerBackgroundImage ?? _appSetting.playerBackgroundImage;
    _appSetting.backgroundBlurValue =
        backgroundBlurValue ?? _appSetting.backgroundBlurValue;
    _appSetting.playerTheme = playerTheme ?? _appSetting.playerTheme;
    final pref = await SharedPreferences.getInstance();
    pref.setString('appSetting', jsonEncode(_appSetting.toJson()));

    notifyListeners();
  }

  Future<AppSetting> loadSetting() async {
    var pref = await SharedPreferences.getInstance();
    final setting = pref.getString('appSetting');
    if (setting != null) {
      var jsonCode = jsonDecode(setting);
      try {
        _appSetting = AppSetting.fromJson(jsonCode);
        notifyListeners();
      } catch (e) {
        pref.remove('appSetting');
      }
    }

    return _appSetting;
  }
}
