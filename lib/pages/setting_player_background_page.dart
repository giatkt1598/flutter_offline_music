import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/blur_image.dart';
import 'package:flutter_offline_music/constants/constant.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:provider/provider.dart';

class SettingPlayerBackgroundPage extends StatefulWidget {
  const SettingPlayerBackgroundPage({super.key});
  static final List<String> images = [
    '',
    'assets/player_bg/player_bg (1).webp',
    'assets/player_bg/player_bg (2).webp',
    'assets/player_bg/player_bg (3).webp',
    'assets/player_bg/player_bg (4).webp',
    'assets/player_bg/player_bg (5).webp',
    'assets/player_bg/player_bg (6).webp',
    'assets/player_bg/player_bg (7).webp',
    'assets/player_bg/player_bg (8).webp',
    'assets/player_bg/player_bg (9).webp',
    'assets/player_bg/player_bg (10).webp',
    'assets/player_bg/player_bg (11).webp',
    'assets/player_bg/player_bg (12).webp',
  ];

  @override
  State<SettingPlayerBackgroundPage> createState() =>
      _SettingPlayerBackgroundPageState();
}

class _SettingPlayerBackgroundPageState
    extends State<SettingPlayerBackgroundPage> {
  late double blurValue;

  @override
  void initState() {
    blurValue =
        Provider.of<SettingProvider>(
          context,
          listen: false,
        ).appSetting.backgroundBlurValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var settingProvider = Provider.of<SettingProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    showBgSettings() async {
      playerProvider.hideMiniPlayer();
      await showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tùy chỉnh',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 30, child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Độ mờ: ${(blurValue * 100).round()}%'),
                          SizedBox(height: 8),
                          Slider(
                            value: blurValue,
                            onChanged: (val) {
                              setState(() {
                                blurValue = val;
                              });
                            },
                            onChangeEnd: (value) {
                              settingProvider.setting(
                                backgroundBlurValue: value,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              );
            },
          );
        },
      );
      playerProvider.showMiniPlayer();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hình nền'),
        actions: [
          IconButton(onPressed: showBgSettings, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.5,
        padding: EdgeInsets.all(8),
        children: [
          for (var img in SettingPlayerBackgroundPage.images)
            BackgroundItem(
              value: img,
              valueGroup: settingProvider.appSetting.playerBackgroundImage,
              onChanged: (val) {
                settingProvider.setting(playerBackgroundImage: val);
              },
            ),
        ],
      ),
    );
  }
}

class BackgroundItem extends StatelessWidget {
  const BackgroundItem({
    super.key,
    required this.value,
    required this.valueGroup,
    required this.onChanged,
  });

  final String valueGroup;
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(value);
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border:
                  value == valueGroup
                      ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      )
                      : null,
            ),
            child: SizedBox(
              width: 200,
              height: 400,
              child:
                  value == ''
                      ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        child: Center(child: Text('Tự động')),
                      )
                      : BlurImageWidget(
                        imagePath: value,
                        size: Size(200, 400),
                        sigmaX: 0,
                        sigmaY: 0,
                      ),
            ),
          ),
          if (value == valueGroup)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                width: 20,
                height: 20,
                child: Center(
                  child: Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
