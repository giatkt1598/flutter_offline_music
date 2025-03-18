import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_pages/default_player_page.dart';
import 'package:flutter_offline_music/pages/player_pages/player_ver_one_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  final Music music;

  const PlayerPage({super.key, required this.music});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  @override
  void initState() {
    super.initState();
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final audioHandler = playerProvider.audioHandler;
    playerProvider.isShowMiniPlayer = false;

    Future play() async {
      if (audioHandler.playlist.isEmpty) {
        await audioHandler.setPlaylistFromMusics(playerProvider.musics);
      }

      if (widget.music.path != audioHandler.currentMediaItem?.id) {
        await audioHandler.stop();
        await audioHandler.playMusic(widget.music);
      }
    }

    play();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    String playerTheme =
        Provider.of<SettingProvider>(context).appSetting.playerTheme;

    final playerWidget = () {
      switch (playerTheme) {
        case 'default':
          return DefaultPlayerPage(music: widget.music);
        case 'one':
          return PlayerVerOnePage(music: widget.music);
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
