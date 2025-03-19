import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/blur_image.dart';
import 'package:flutter_offline_music/components/player_header.dart';
import 'package:flutter_offline_music/components/music_playlist.dart';
import 'package:flutter_offline_music/components/simple_tab.dart';
import 'package:flutter_offline_music/constants/constant.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:flutter_offline_music/components/audio_slider.dart';
import 'package:flutter_offline_music/components/auto_scroll_text.dart';
import 'package:flutter_offline_music/components/countdown.dart';
import 'package:flutter_offline_music/components/music_disc_illustrator.dart';
import 'package:flutter_offline_music/pages/player_pages/base/base_player_widget_state.dart';
import 'package:flutter_offline_music/pages/player_pages/base/base_player_widget.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:just_audio/just_audio.dart';

class DefaultPlayerPage extends BasePlayerWidget {
  const DefaultPlayerPage({super.key});

  @override
  State<BasePlayerWidget> createState() => _DefaultPlayerPageState();
}

class _DefaultPlayerPageState extends BasePlayerWidgetState
    with TickerProviderStateMixin {
  int tabIndex = 1;

  @override
  void onInitState() {}

  @override
  void onDispose() {}

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
    final appSetting = Provider.of<SettingProvider>(context).appSetting;
    final backgroundImage = music.thumbnail ?? appSetting.playerBackgroundImage;
    bool isDarkBottom =
        backgroundImage.isNotEmpty ||
        Theme.of(context).brightness == Brightness.light;

    return DefaultTextStyle(
      style: TextStyle(color: Colors.white),
      child: IconTheme(
        data: IconThemeData(color: Colors.white),
        child: Stack(
          children: [
            if (backgroundImage.isNotEmpty)
              BlurImageWidget(
                imagePath: backgroundImage,
                size: Size(SharedData.fullWidth, SharedData.fullHeight),
                sigmaX:
                    appSetting.backgroundBlurValue *
                    Constants.backgroundBlurSigmaMaxValue,
                sigmaY:
                    appSetting.backgroundBlurValue *
                    Constants.backgroundBlurSigmaMaxValue,
              ),
            if (isDarkBottom)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(
                        alpha: 0.7,
                      ), // ✅ Bóng mờ màu đen ở dưới
                    ],
                  ),
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
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                      )
                      : null,
            ),

            Column(
              children: [
                SizedBox(height: SharedData.statusBarHeight),
                PlayerHeader(
                  music: music,
                  playerTab:
                      tabIndex == 0 ? PlayerTab.playlist : PlayerTab.audio,
                ),
                Expanded(
                  child: SimpleTab(
                    initialIndex: tabIndex,
                    tabViews: [MusicPlaylist(), _DefaultPlayer()],
                    onTabChanged: (value) {
                      setState(() {
                        tabIndex = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultPlayer extends BasePlayerWidget {
  const _DefaultPlayer();

  @override
  State<BasePlayerWidget> createState() => _DefaultPlayerState();
}

class _DefaultPlayerState extends BasePlayerWidgetState {
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
    return DefaultTextStyle(
      style: TextStyle(color: Colors.white),
      child: IconTheme(
        data: IconThemeData(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (audioHandler.stopTime != null)
                  DefaultTextStyle(
                    style: TextStyle(fontSize: 12),
                    child: Opacity(
                      opacity: 0.5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${tr().stopAfter} '),
                          Countdown(endTime: audioHandler.stopTime),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: toggleFavorite,
                    child: Container(
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          Center(child: MusicDiscIllustrator(music: music)),
                          if (music.isFavorite)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 12,
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      100,
                                      151,
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
                Column(
                  children: [
                    Column(
                      children: [
                        Column(
                          children: [
                            AutoScrollText(
                              isCenter: true,
                              text: music.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Opacity(
                              opacity: 0.5,
                              child: Text(
                                music.artist ?? tr().music_unknownArtist,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: AudioSlider(
                            value: min(
                              position.inSeconds.toDouble(),
                              duration.inSeconds.toDouble(),
                            ),
                            min: 0,
                            max: duration.inSeconds.toDouble(),
                            onChanged:
                                (value) =>
                                    seek(Duration(seconds: value.toInt())),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
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
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: toggleShuffle,
                          icon: Opacity(
                            opacity: isShuffle ? 1 : 0.3,
                            child: Icon(Icons.shuffle_sharp),
                          ),
                        ),
                        IconButton(
                          onPressed: hasPrevious ? skipToPrevious : null,
                          icon: Icon(Icons.skip_previous_rounded),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ), // 👈 Viền đen
                          ),
                          child: IconButton(
                            onPressed: playPause,
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
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
                                    opacity: 0.3,
                                    child: Icon(Icons.repeat_rounded),
                                  ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
