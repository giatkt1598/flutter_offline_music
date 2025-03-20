import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_playlist.dart';
import 'package:flutter_offline_music/components/player_header.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:flutter_offline_music/utilities/theme_helper.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final music = playerProvider.audioHandler.currentMusic;

    if (music == null) return Container();

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Theme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: 0.5),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Mức độ nhòe
          child: Container(
            color: Colors.black12, // Lớp phủ mờ
          ),
        ),
        Positioned.fill(
          child: Theme(
            data: ThemeData.dark(),
            child: DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: Column(
                children: [
                  SizedBox(height: SharedData.statusBarHeight),
                  PlayerHeader(music: music, playerTab: PlayerTab.playlist),
                  Expanded(
                    child: MusicPlaylist(
                      onCurrentItemPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
