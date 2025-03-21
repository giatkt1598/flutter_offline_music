import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/audio_slider.dart';
import 'package:flutter_offline_music/components/music_item_menu.dart';
import 'package:flutter_offline_music/components/music_playlist.dart';
import 'package:flutter_offline_music/components/rotating_circle_image.dart';
import 'package:flutter_offline_music/components/simple_tab.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_pages/base/base_player_widget.dart';
import 'package:flutter_offline_music/pages/player_pages/base/base_player_widget_state.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:flutter_offline_music/utilities/string_extensions.dart';
import 'package:flutter_offline_music/utilities/theme_helper.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:just_audio/just_audio.dart';

class PlayerVerThreePage extends BasePlayerWidget {
  const PlayerVerThreePage({super.key});

  @override
  State<BasePlayerWidget> createState() => _PlayerVerThreePageState();
}

class _PlayerVerThreePageState extends BasePlayerWidgetState {
  int tabIndex = 1;

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
    final bgImage =
        music.thumbnail ??
        context
            .getSettingProvider()
            .appSetting
            .playerBackgroundImage
            .toNullIfEmpty();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: isDarkMode() ? Colors.black : Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              spacing: 16,
              children: [
                SizedBox(height: SharedData.statusBarHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: isDarkMode() ? Colors.white30 : Colors.black26,
                      ),
                    ),
                  ],
                ),

                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    key: ValueKey(tabIndex),
                    tabIndex == 0 ? tr().playlistTitle : tr().nowPlayingTitle,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).cardColor,
                            image:
                                bgImage == null
                                    ? null
                                    : DecorationImage(
                                      image: FileImage(File(bgImage)),
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 16),
                        child: SimpleTab(
                          initialIndex: tabIndex,
                          onTabChanged: (value) {
                            setState(() {
                              tabIndex = value;
                            });
                          },
                          tabViews: [
                            MusicPlaylist(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (bgImage != null)
                                  Expanded(
                                    child: Center(
                                      child: RotatingCircleImage(
                                        bgImage: bgImage,
                                        isRotate: isPlaying,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color:
                                          isDarkMode() && bgImage == null
                                              ? Colors.white12
                                              : Colors.black38,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              spacing: 8,
                                              children: [
                                                Text(
                                                  music.title,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  music.artist ??
                                                      tr().music_unknownArtist,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color:
                        isDarkMode()
                            ? Theme.of(context).cardColor
                            : Colors.white,
                    boxShadow:
                        isDarkMode()
                            ? null
                            : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.purple,
                                  Colors.pink,
                                  Colors.blue,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: IconButton(
                              onPressed: toggleFavorite,
                              icon: Icon(
                                music.isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          MusicItemMenu(
                            music: music,
                            showMiniPlayer: false,
                            type: MusicMenuType.inPlayer,
                            icon: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color ??
                                      Colors.white,
                                ),
                              ),
                              child: Icon(Icons.more_horiz, size: 20),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AudioSlider(
                          activeTrackColor:
                              isDarkMode()
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                          inactiveTrackColor:
                              isDarkMode()
                                  ? Colors.white24
                                  : Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: .24),
                          thumbColor:
                              isDarkMode()
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                          thumbShape:
                              (isDragging) => RoundSliderThumbShape(
                                enabledThumbRadius: isDragging ? 8 : 8,
                              ),
                          value: min(
                            position.inSeconds.toDouble(),
                            duration.inSeconds.toDouble(),
                          ),
                          min: 0,
                          max: duration.inSeconds.toDouble(),
                          onChanged:
                              (value) => seek(Duration(seconds: value.toInt())),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(fDurationHHMMSS(position, short: true)),
                            Text(fDurationHHMMSS(duration, short: true)),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Opacity(
                            opacity: isShuffle ? 1 : 0.4,
                            child: IconButton(
                              onPressed: toggleShuffle,
                              icon: Icon(Icons.shuffle),
                            ),
                          ),
                          IconButton(
                            onPressed: hasPrevious ? skipToPrevious : null,
                            icon: Icon(Icons.skip_previous_rounded),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange,
                                  Colors.red,
                                  Colors.pink,
                                  Colors.purple,
                                ],
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
                            onPressed: hasNext ? skipToNext : null,
                            icon: Icon(Icons.skip_next_rounded),
                          ),
                          IconButton(
                            onPressed: changeLoopMode,
                            icon:
                                loopMode == LoopMode.all
                                    ? Icon(Icons.repeat_rounded)
                                    : loopMode == LoopMode.one
                                    ? Icon(Icons.repeat_one_rounded)
                                    : Opacity(
                                      opacity: 0.4,
                                      child: Icon(Icons.repeat_rounded),
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
