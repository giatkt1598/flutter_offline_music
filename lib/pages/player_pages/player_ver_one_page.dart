import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_pages/base/base_player_widget.dart';
import 'package:flutter_offline_music/pages/player_pages/base/base_player_widget_state.dart';
import 'package:flutter_offline_music/pages/select_player_theme_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';
import 'package:just_audio/just_audio.dart';

class PlayerVerOnePage extends BasePlayerWidget {
  const PlayerVerOnePage({super.key, required super.music});

  @override
  State<BasePlayerWidget> createState() => _PlayerVerOnePageState();
}

class _PlayerVerOnePageState extends BasePlayerWidgetState {
  @override
  Widget buildUI({
    required BuildContext context,
    required PlayerProvider playerProvider,
    required AppAudioHandler audioHandler,
    required Music music,
    required String? backgroundImage,
    required Duration duration,
    required Duration position,
    required bool isPlaying,
    required bool hasNext,
    required bool hasPrevious,
    required bool isShuffle,
    required LoopMode loopMode,
    required Future<void> Function() toggleFavorite,
    required Future<void> Function() toggleShuffle,
    required Future<void> Function() skipToPrevious,
    required Future<void> Function() skipToNext,
    required Future<void> Function() playPause,
    required Future<void> Function(Duration position) seek,
    required Future<void> Function() changeLoopMode,
  }) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SelectPlayerThemePage(music: music),
                ),
              );
            },
            child: Text('Change UI'),
          ),
          Container(child: Center(child: Text('Player ver 2'))),
        ],
      ),
    );
  }
}
