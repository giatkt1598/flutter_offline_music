import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_pages/default_player_page.dart';
import 'package:flutter_offline_music/pages/player_pages/player_ver_one_page.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatelessWidget {
  final Music music;

  const PlayerPage({super.key, required this.music});

  @override
  Widget build(BuildContext context) {
    String playerTheme =
        Provider.of<SettingProvider>(context).appSetting.playerTheme;

    switch (playerTheme) {
      case 'default':
        return DefaultPlayerPage(music: music);
      case 'one':
        return PlayerVerOnePage(music: music);
      default:
        return Container();
    }
  }
}
