import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_item_menu.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

enum PlayerTab { playlist, audio }

class PlayerHeader extends StatefulWidget {
  const PlayerHeader({super.key, required this.music, required this.playerTab});

  final Music music;
  final PlayerTab playerTab;
  @override
  State<PlayerHeader> createState() => _PlayerHeaderState();
}

class _PlayerHeaderState extends State<PlayerHeader> {
  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.keyboard_arrow_down_rounded),
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Text(
            key: ValueKey(widget.playerTab),
            {
              PlayerTab.audio: tr().nowPlayingTitle,
              PlayerTab.playlist: tr().playlistTitle,
            }[widget.playerTab]!,
          ),
        ),
        if (widget.playerTab == PlayerTab.audio)
          MusicItemMenu(
            type: MusicMenuType.inPlayer,
            showMiniPlayer: false,
            music: widget.music,
            afterToggleHide: () {
              playerProvider.musics.removeWhere((x) => x.id == widget.music.id);
              playerProvider.setMusics(playerProvider.musics);
              Navigator.of(context).pop();
            },
          )
        else
          IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
      ],
    );
  }
}
