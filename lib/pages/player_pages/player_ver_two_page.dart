import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/audio_slider.dart';
import 'package:flutter_offline_music/components/music_item_menu.dart';
import 'package:flutter_offline_music/components/music_playlist.dart';
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

class PlayerVerTwoPage extends BasePlayerWidget {
  const PlayerVerTwoPage({super.key});

  @override
  State<BasePlayerWidget> createState() => _PlayerVerTwoPageState();
}

class _PlayerVerTwoPageState extends BasePlayerWidgetState {
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
    final bg =
        music.thumbnail ??
        context
            .getSettingProvider()
            .appSetting
            .playerBackgroundImage
            .toNullIfEmpty();
    var audioPlayerTab = Column(
      children: [
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      music.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        music.artist ?? tr().music_unknownArtist,
                      ),
                    ),
                  ],
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [Colors.purple, Colors.pink, Colors.blue],
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
                type: MusicMenuType.inPlayer,
                showMiniPlayer: false,
                icon: Icon(Icons.more_horiz_sharp),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AudioSlider(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
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
            onChanged: (value) => seek(Duration(seconds: value.toInt())),
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
                    // Colors.orange,
                    // Colors.red,
                    // Colors.pink,
                    // Colors.purple,
                    Colors.lightBlue,
                    Colors.purpleAccent,
                    Colors.pink,
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

        SizedBox(height: 40),
      ],
    );
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child:
                  bg == null
                      ? Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Spacer(),
                            Flexible(
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/music_note_2.png',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Spacer(flex: 2),
                          ],
                        ),
                      )
                      : Image.file(File(bg), fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Column(
                children: [
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [Colors.black38, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Spacer(flex: 2),
                ],
              ),
            ),

            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child:
                  tabIndex == 0
                      ? Container(
                        key: ValueKey(tabIndex),
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      )
                      : Column(
                        key: ValueKey(tabIndex),
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Spacer(),
                          Container(
                            width: double.infinity,
                            height: 250,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black],
                              ),
                            ),
                          ),
                          Container(height: 200, color: Colors.black),
                        ],
                      ),
            ),
            Positioned.fill(
              child: Column(
                children: [
                  SizedBox(height: SharedData.statusBarHeight),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipOval(
                          child: Container(
                            height: 40,
                            width: 40,
                            color: Colors.black26,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.arrow_back),
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child:
                              tabIndex == 0
                                  ? Text(
                                    key: ValueKey(tabIndex),
                                    tr().playlistTitle,
                                  )
                                  : null,
                        ),
                        Opacity(
                          opacity: 0,
                          child: SizedBox(width: 40, height: 40),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SimpleTab(
                      initialIndex: tabIndex,
                      showTabBar: false,
                      tabViews: [MusicPlaylist(), audioPlayerTab],
                      onTabChanged: (value) {
                        setState(() {
                          tabIndex = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
