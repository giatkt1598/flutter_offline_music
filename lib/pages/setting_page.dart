import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/show_confirm_dialog.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/pages/language_list_page.dart';
import 'package:flutter_offline_music/pages/setting_player_background_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/services/database_helper.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool skipSilent = true;
  String appVersion = "";
  @override
  void initState() {
    PackageInfo.fromPlatform().then((rs) {
      setState(() {
        appVersion = rs.version;
      });
    });

    super.initState();
  }

  void handleDeleteData(BuildContext context) async {
    bool? confirmed = await showConfirmDialog(
      context: context,
      title: "Xóa dữ liệu",
      message: "Xóa tất cả dữ liệu, sau khi xóa, bạn cần khởi động lại app?",
    );
    if (confirmed == true) {
      Future<void> clearTemporaryDirectory() async {
        final tempDir = await getTemporaryDirectory(); // Lấy thư mục tạm
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true); // Xóa toàn bộ file & thư mục con
        }
      }

      await DatabaseHelper.resetDatabase();
      await clearTemporaryDirectory();
      ToastService.showSuccess('Đã xóa dữ liệu, vui lòng khởi động lại app...');
      Timer(Duration(seconds: 1), () {
        exit(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingProvider = Provider.of<SettingProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final appSetting = settingProvider.appSetting;
    String? backgroundName = '';
    if (appSetting.playerBackgroundImage.isEmpty) {
      backgroundName = 'Tự động';
    } else {
      backgroundName =
          'Hình ${SettingPlayerBackgroundPage.images.indexOf(appSetting.playerBackgroundImage) + 1}';
    }
    return Scaffold(
      appBar: AppBar(title: Text(tr().settingTitle), actions: []),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingGroup(title: tr().setting_themeTitle),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var mode in [
                    ThemeMode.light,
                    ThemeMode.dark,
                    ThemeMode.system,
                  ])
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            settingProvider.setting(themeMode: mode);
                          },
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                                image: DecorationImage(
                                  image: AssetImage(
                                    {
                                      ThemeMode.system:
                                          'assets/moon_mix_sun.jpg',
                                      ThemeMode.dark: 'assets/moon.png',
                                      ThemeMode.light: 'assets/sun.png',
                                    }[mode]!,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          {
                            ThemeMode.system: tr().theme_auto,
                            ThemeMode.dark: tr().theme_darkMode,
                            ThemeMode.light: tr().theme_lightMode,
                          }[mode]!,
                        ),
                        Transform.translate(
                          offset: Offset(0, -10),
                          child: Radio(
                            value: mode,
                            groupValue: appSetting.themeMode,
                            onChanged: (val) {
                              settingProvider.setting(themeMode: val);
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SettingItemSelect(
                settingName: tr().languageTitle,
                settingValue: tr().langOptionDisplayName(
                  appSetting.languageCode,
                ),
                settingPage: LanguageListPage(),
              ),
              Divider(),
              SizedBox(height: 8),
              SettingGroup(title: tr().setting_playerTitle),
              SettingItemSwitch(
                value: appSetting.skipSilent,
                onChanged: (enable) {
                  settingProvider.setting(skipSilent: enable);
                  playerProvider.audioHandler.player.setSkipSilenceEnabled(
                    enable,
                  );
                },
                title: tr().settingPlayer_skipSilence,
              ),
              SettingItemSwitch(
                value: appSetting.autoVolumnPausePlay,
                onChanged: (val) {
                  settingProvider.setting(autoVolumnPausePlay: val);
                },
                title: tr().settingPlayer_autoVolume,
              ),
              SettingItemSwitch(
                value: appSetting.autoScanFiles,
                onChanged: (val) {
                  settingProvider.setting(autoScanFiles: val);
                },
                title: tr().settingPlayer_autoScan,
              ),
              SettingItemSelect(
                settingName: tr().settingPlayer_background,
                settingPage: SettingPlayerBackgroundPage(),
                settingValue: backgroundName,
              ),
              Divider(),
              SizedBox(height: 8),
              SettingGroup(title: tr().setting_aboutTitle),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                onTap: () {},
                title: Text(tr().about_intro),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                onTap: () {},
                title: Row(
                  children: [
                    Expanded(child: Text(tr().about_intro)),
                    Opacity(opacity: 0.4, child: Text(appVersion)),
                  ],
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                onTap: () {},
                title: Text(tr().about_contact),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                onTap: () => handleDeleteData(context),
                title: Text(
                  tr().setting_deleteDataPermanently,
                  style: TextStyle(color: Colors.red),
                ),
              ),

              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingItemSelect extends StatelessWidget {
  const SettingItemSelect({
    super.key,
    required this.settingName,
    required this.settingPage,
    required this.settingValue,
  });

  final String settingName;
  final String settingValue;
  final Widget settingPage;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => settingPage,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                      position: Tween(
                        begin: Offset(1, 0),
                        end: Offset(0, 0),
                      ).animate(animation),
                      child: child,
                    ),
          ),
        );
      },
      title: Row(
        children: [
          Expanded(child: Text(settingName)),
          Opacity(opacity: 0.4, child: Text(settingValue)),
          Opacity(
            opacity: 0.4,
            child: Icon(Icons.keyboard_arrow_right_outlined),
          ),
        ],
      ),
    );
  }
}

class SettingGroup extends StatelessWidget {
  const SettingGroup({super.key, required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}

class SettingItemSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;

  const SettingItemSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      minTileHeight: 4,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 24,
        children: [
          Expanded(child: Text(title, style: TextStyle(fontSize: 14))),
          Transform.translate(
            offset: Offset(10, 0),
            child: Transform.scale(
              scale: 0.7,
              child: SizedBox(
                height: 30,
                child: Switch(value: value, onChanged: onChanged),
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        onChanged(!value);
      },
    );
  }
}
