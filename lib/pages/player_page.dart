import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/audio_slider.dart';
import 'package:flutter_offline_music/components/auto_scroll_text.dart';
import 'package:flutter_offline_music/components/blur_image.dart';
import 'package:flutter_offline_music/components/countdown.dart';
import 'package:flutter_offline_music/components/music_disc_illustrator.dart';
import 'package:flutter_offline_music/components/music_item_menu.dart';
import 'package:flutter_offline_music/constants/constant.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.music});

  final Music music;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  Duration position = Duration.zero;
  late StreamSubscription<Duration?> positionSubscription;
  @override
  void initState() {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.isShowMiniPlayer = false;
    final audioHandler = playerProvider.audioHandler;
    if (widget.music.path != audioHandler.currentMediaItem?.id) {
      audioHandler.stop().then((_) {
        audioHandler.playMusic(widget.music);
      });
    }

    setState(() {
      positionSubscription = audioHandler.player.positionStream.listen((p) {
        setState(() {
          position = p;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    positionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    final settingProvider = Provider.of<SettingProvider>(context);
    final thumbnail = audioHandler.currentMediaItem?.artUri?.toFilePath();
    final backgroundImage =
        thumbnail ?? settingProvider.appSetting.playerBackgroundImage;
    bool isDarkBottom =
        backgroundImage.isNotEmpty ||
        Theme.of(context).brightness == Brightness.light;
    final duration = audioHandler.currentMediaItem?.duration ?? Duration.zero;

    final currentPosition =
        audioHandler.playingMediaItemId == audioHandler.currentMediaItem?.id
            ? position
            : Duration.zero;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        playerProvider.isShowMiniPlayer = true;
      },
      child: Stack(
        children: [
          if (backgroundImage.isNotEmpty)
            BlurImageWidget(
              imagePath: backgroundImage,
              size: Size(SharedData.fullWidth, SharedData.fullHeight),
              sigmaX:
                  settingProvider.appSetting.backgroundBlurValue *
                  Constants.backgroundBlurSigmaMaxValue,
              sigmaY:
                  settingProvider.appSetting.backgroundBlurValue *
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

          SafeArea(
            child: DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: IconTheme(
                data: IconThemeData(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: SharedData.statusBarHeight),
                        DefaultTextStyle(
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.9),
                                blurRadius: 1,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: IconTheme(
                            data: IconThemeData(
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.9),
                                  blurRadius: 1,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.keyboard_arrow_down_rounded),
                                ),
                                Column(
                                  children: [
                                    Text('Phát từ'),
                                    Text('Danh sách phát A'),
                                    Text('-'),
                                  ],
                                ),
                                MusicItemMenu(
                                  showMiniPlayer: false,
                                  music: widget.music,
                                  afterToggleHide: () {
                                    playerProvider.musics.removeWhere(
                                      (x) => x.id == widget.music.id,
                                    );
                                    playerProvider.setMusics(
                                      playerProvider.musics,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (audioHandler.stopTime != null)
                          DefaultTextStyle(
                            style: TextStyle(fontSize: 10),
                            child: Opacity(
                              opacity: 0.5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Dừng sau '),
                                  Countdown(endTime: audioHandler.stopTime),
                                ],
                              ),
                            ),
                          ),
                        Expanded(child: MusicDiscIllustrator()),
                        Column(
                          children: [
                            Column(
                              children: [
                                Column(
                                  children: [
                                    // Text(
                                    //   playerProvider.music?.name ?? '',
                                    //   style: TextStyle(
                                    //     fontWeight: FontWeight.bold,
                                    //     fontSize: 20,
                                    //   ),
                                    // ),
                                    AutoScrollText(
                                      isCenter: true,
                                      text:
                                          audioHandler
                                              .currentMediaItem
                                              ?.title ??
                                          '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Opacity(
                                      opacity: 0.5,
                                      child: Text(
                                        audioHandler.currentMediaItem?.artist ??
                                            '<Không rõ tác giả>',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                  ],
                                ),
                                AudioSlider(
                                  value: min(
                                    currentPosition.inSeconds.toDouble(),
                                    duration.inSeconds.toDouble(),
                                  ),
                                  min: 0,
                                  max: duration.inSeconds.toDouble(),
                                  onChanged:
                                      (value) => audioHandler.seek(
                                        Duration(seconds: value.toInt()),
                                      ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        fDurationHHMMSS(
                                          currentPosition,
                                          short: true,
                                        ),
                                      ),
                                      Text(
                                        fDurationHHMMSS(duration, short: true),
                                      ),
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
                                  onPressed: () {
                                    audioHandler.setShuffle(
                                      !audioHandler.isShuffle,
                                    );
                                  },
                                  icon: Opacity(
                                    opacity: audioHandler.isShuffle ? 1 : 0.3,
                                    child: Icon(Icons.shuffle_sharp),
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      audioHandler.canPrevious
                                          ? audioHandler.skipToPrevious
                                          : null,
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
                                    onPressed: () {
                                      if (audioHandler.playing) {
                                        audioHandler.pause();
                                      } else {
                                        audioHandler.play();
                                      }
                                    },
                                    icon: Icon(
                                      audioHandler.playing
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    iconSize: 50,
                                    style: ButtonStyle(),
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      audioHandler.canNext
                                          ? audioHandler.skipToNext
                                          : null,
                                  icon: Icon(Icons.skip_next_rounded),
                                ),
                                IconButton(
                                  onPressed: () {
                                    switch (audioHandler.player.loopMode) {
                                      case LoopMode.off:
                                        audioHandler.player.setLoopMode(
                                          LoopMode.all,
                                        );
                                        break;
                                      case LoopMode.all:
                                        audioHandler.player.setLoopMode(
                                          LoopMode.one,
                                        );
                                        break;
                                      default:
                                        audioHandler.player.setLoopMode(
                                          LoopMode.off,
                                        );
                                        break;
                                    }
                                  },
                                  icon:
                                      audioHandler.player.loopMode ==
                                              LoopMode.all
                                          ? Icon(Icons.repeat_rounded)
                                          : audioHandler.player.loopMode ==
                                              LoopMode.one
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
            ),
          ),
        ],
      ),
    );
  }
}
