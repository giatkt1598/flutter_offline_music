import 'package:flutter/material.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('applies initial theme mode and persists setting', () async {
      final provider = SettingProvider(initialThemeMode: ThemeMode.dark);
      expect(provider.appSetting.themeMode, ThemeMode.dark);

      await provider.setting(
        languageCode: 'vi',
        keepScreenOn: true,
        playerTheme: 'one',
      );

      final loaded = SettingProvider();
      final appSetting = await loaded.loadSetting();

      expect(appSetting.languageCode, 'vi');
      expect(appSetting.keepScreenOn, isTrue);
      expect(appSetting.playerTheme, 'one');
    });
  });
}
