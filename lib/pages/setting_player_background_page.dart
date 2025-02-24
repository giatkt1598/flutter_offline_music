import 'package:flutter/material.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:provider/provider.dart';

class SettingPlayerBackgroundPage extends StatefulWidget {
  const SettingPlayerBackgroundPage({super.key});
  static final List<String> images = [
    '',
    'assets/player_bg/player_bg (1).jpg',
    'assets/player_bg/player_bg (1).webp',
    'assets/player_bg/player_bg (2).jpg',
    'assets/player_bg/player_bg (2).webp',
    'assets/player_bg/player_bg (3).jpg',
    'assets/player_bg/player_bg (3).webp',
    'assets/player_bg/player_bg (4).jpg',
    'assets/player_bg/player_bg (4).webp',
    'assets/player_bg/player_bg (5).webp',
    'assets/player_bg/player_bg (6).webp',
    'assets/player_bg/player_bg (7).webp',
    'assets/player_bg/player_bg (8).webp',
  ];

  @override
  State<SettingPlayerBackgroundPage> createState() =>
      _SettingPlayerBackgroundPageState();
}

class _SettingPlayerBackgroundPageState
    extends State<SettingPlayerBackgroundPage> {
  @override
  Widget build(BuildContext context) {
    var settingProvider = Provider.of<SettingProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Hình nền')),
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
                      : Image.asset(
                        value,
                        fit: BoxFit.cover, // Ensures it covers the screen
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        alignment: Alignment.center,
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
