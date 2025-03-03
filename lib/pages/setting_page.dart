import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/show_confirm_dialog.dart';
import 'package:flutter_offline_music/pages/language_list_page.dart';
import 'package:flutter_offline_music/pages/setting_player_background_page.dart';
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
    final appSetting = settingProvider.appSetting;
    String? backgroundName = '';
    if (appSetting.playerBackgroundImage.isEmpty) {
      backgroundName = 'Tự động';
    } else {
      backgroundName =
          'Hình ${SettingPlayerBackgroundPage.images.indexOf(appSetting.playerBackgroundImage) + 1}';
    }
    return Scaffold(
      appBar: AppBar(title: Text("Cài đặt"), actions: []),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingGroup(title: 'Giao diện chủ đề'),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var mode in [
                    ThemeMode.system,
                    ThemeMode.dark,
                    ThemeMode.light,
                  ])
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            settingProvider.setting(themeMode: mode);
                          },
                          child: SizedBox(
                            width: 100,
                            height: 140,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 51, 51, 51),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    spreadRadius: 5,
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
                            ThemeMode.system: "Hệ thống",
                            ThemeMode.dark: "Tối",
                            ThemeMode.light: "Sáng",
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
                settingName: 'Ngôn ngữ',
                settingValue: 'Tiếng Việt',
                settingPage: LanguageListPage(),
              ),
              Divider(),
              SizedBox(height: 8),
              SettingGroup(title: 'Trình phát nhạc'),
              SettingItemSwitch(
                value: appSetting.skipSilent,
                onChanged: (val) {
                  settingProvider.setting(skipSilent: val);
                },
                title: "Bỏ qua khoảng lặng",
              ),
              SettingItemSwitch(
                value: appSetting.autoVolumnPausePlay,
                onChanged: (val) {
                  settingProvider.setting(autoVolumnPausePlay: val);
                },
                title: "To/nhỏ dần khi phát/tạm dừng, chuyển bài",
              ),
              SettingItemSwitch(
                value: appSetting.autoScanFiles,
                onChanged: (val) {
                  settingProvider.setting(autoScanFiles: val);
                },
                title: "Tự động quét nhạc",
              ),
              SettingItemSelect(
                settingName: 'Hình nền',
                settingPage: SettingPlayerBackgroundPage(),
                settingValue: backgroundName,
              ),
              Divider(),
              SizedBox(height: 8),
              SettingGroup(title: 'Thông tin ứng dụng'),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                onTap: () {},
                title: Text('Giới thiệu'),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                onTap: () {},
                title: Row(
                  children: [
                    Expanded(child: Text('Phiên bản')),
                    Opacity(opacity: 0.4, child: Text(appVersion)),
                  ],
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                onTap: () {},
                title: Text('Liên hệ & hỗ trợ'),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                onTap: () => handleDeleteData(context),
                title: Text('Xóa dữ liệu', style: TextStyle(color: Colors.red)),
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
