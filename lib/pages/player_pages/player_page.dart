import 'package:flutter/material.dart';
import 'package:flutter_offline_music/pages/player_pages/default_player_page.dart';
import 'package:flutter_offline_music/pages/player_pages/player_ver_one_page.dart';
import 'package:flutter_offline_music/pages/player_pages/player_ver_three_page.dart';
import 'package:flutter_offline_music/pages/player_pages/player_ver_two_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  @override
  void initState() {
    super.initState();
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.isShowMiniPlayer = false;
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    String playerTheme =
        Provider.of<SettingProvider>(context).appSetting.playerTheme;

    final music = playerProvider.audioHandler.currentMusic;
    if (music == null) return Container();

    final playerWidget = () {
      switch (playerTheme) {
        case 'default':
          return DefaultPlayerPage();
        case 'one':
          return PlayerVerOnePage();
        case 'two':
          return PlayerVerTwoPage();
        case 'three':
          return PlayerVerThreePage();
        default:
          return Container();
      }
    }();

    return PopScope<bool>(
      onPopInvokedWithResult: (didPop, result) {
        if (result != true) {
          playerProvider.isShowMiniPlayer = true;
        }
      },
      child: playerWidget,
    );
  }
}
