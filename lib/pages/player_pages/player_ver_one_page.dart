import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/audio_slider_flat.dart';
import 'package:flutter_offline_music/components/audio_waves.dart';
import 'package:flutter_offline_music/components/auto_scroll_text.dart';
import 'package:flutter_offline_music/components/count_down_icon.dart';
import 'package:flutter_offline_music/components/player_header.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_pages/base/base_player_widget.dart';
import 'package:flutter_offline_music/pages/player_pages/base/base_player_widget_state.dart';
import 'package:flutter_offline_music/pages/playlist_page.dart';
import 'package:flutter_offline_music/pages/select_player_theme_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:flutter_offline_music/utilities/theme_helper.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';

class PlayerVerOnePage extends BasePlayerWidget {
  const PlayerVerOnePage({super.key, required super.music});

  @override
  State<BasePlayerWidget> createState() => _PlayerVerOnePageState();
}

class _PlayerVerOnePageState extends BasePlayerWidgetState {
  final sampleWaves = List.generate(30, (index) => Random().nextDouble());

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
    openPlaylistPage() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(),
        builder: (context) {
          return SizedBox(height: SharedData.fullHeight, child: PlaylistPage());
        },
      );
    }

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: SharedData.statusBarHeight),
          PlayerHeader(music: music, playerTab: PlayerTab.audio),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                spacing: 16,
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: SharedData.fullWidth * 0.7,
                        height: SharedData.fullWidth * 0.7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: Offset.zero,
                            ),
                          ],
                          color: Theme.of(context).cardColor,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child:
                              music.thumbnail != null
                                  ? Image.file(
                                    File(music.thumbnail!),
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    'assets/music_note_2.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.none,
                                  ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoScrollText(
                            text: music.title,
                            containerWidth: 300,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Opacity(
                            opacity: 0.4,
                            child: Text(
                              music.artist ?? '<Không rõ tác giả>',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => playerProvider.setStopTime(context),
                        icon: CountDownIcon(endTime: audioHandler.stopTime),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: AudioWaves(playing: isPlaying),
                        ),
                        SizedBox(height: 16),
                        AudioSliderFlat(
                          value: min(
                            position.inSeconds.toDouble(),
                            duration.inSeconds.toDouble(),
                          ),
                          min: 0,
                          max: duration.inSeconds.toDouble(),
                          onChanged:
                              (value) => seek(Duration(seconds: value.toInt())),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(fDurationHHMMSS(position, short: true)),
                              Text(fDurationHHMMSS(duration, short: true)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      SelectPlayerThemePage(music: music),
                            ),
                          );
                        },
                        icon: Icon(Icons.color_lens_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          seek(position - Duration(seconds: 10));
                        },
                        icon: Icon(Icons.replay_10_rounded),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: IconButton(
                          onPressed: playPause,
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: isDarkMode() ? null : Colors.white,
                          ),
                          iconSize: 50,
                          style: ButtonStyle(),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          seek(position + Duration(seconds: 30));
                        },
                        icon: Icon(Icons.forward_30_rounded),
                      ),
                      IconButton(
                        onPressed: toggleFavorite,
                        icon: Icon(
                          music.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: music.isFavorite ? Colors.pinkAccent : null,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 32),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset.zero,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: hasPrevious ? skipToPrevious : null,
                          icon: Icon(Icons.fast_rewind_rounded),
                        ),
                        Opacity(
                          opacity: isShuffle ? 1 : 0.4,
                          child: IconButton(
                            onPressed: toggleShuffle,
                            icon: FaIcon(FontAwesomeIcons.shuffle, size: 16),
                          ),
                        ),
                        if (loopMode == LoopMode.one)
                          IconButton(
                            onPressed: changeLoopMode,
                            icon: Stack(
                              children: [
                                FaIcon(FontAwesomeIcons.repeat, size: 16),
                                Positioned.fill(
                                  child: Center(
                                    child: Text(
                                      '1',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Opacity(
                            opacity: loopMode != LoopMode.off ? 1 : 0.4,
                            child: IconButton(
                              onPressed: changeLoopMode,
                              icon: FaIcon(FontAwesomeIcons.repeat, size: 16),
                            ),
                          ),
                        IconButton(
                          onPressed: openPlaylistPage,
                          icon: Icon(Icons.queue_music),
                        ),
                        IconButton(
                          onPressed: hasNext ? skipToNext : null,
                          icon: Icon(Icons.fast_forward_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
