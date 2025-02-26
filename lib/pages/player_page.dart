import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/auto_scroll_text.dart';
import 'package:flutter_offline_music/components/music_disc_illustrator.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.music});

  final Music music;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late StreamSubscription<Duration?> durationSubscription;
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
      durationSubscription = audioHandler.player.durationStream.listen((d) {
        setState(() {
          duration = d ?? Duration.zero;
        });
      });
    });
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
    durationSubscription.cancel();
    positionSubscription.cancel();
    super.dispose();
  }

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    final settingProvider = Provider.of<SettingProvider>(context);
    final thumbnail = audioHandler.currentMediaItem?.artUri?.toFilePath();
    final backgroundImage = settingProvider.appSetting.playerBackgroundImage;
    bool isDarkBottom =
        backgroundImage.isNotEmpty ||
        thumbnail != null ||
        Theme.of(context).brightness == Brightness.light;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        playerProvider.isShowMiniPlayer = true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            if (thumbnail != null)
              Image.file(
                File(thumbnail), // Change to your image
                fit: BoxFit.cover, // Ensures it covers the screen
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
              )
            else if (backgroundImage.isNotEmpty)
              Image.asset(
                backgroundImage,
                fit: BoxFit.cover, // Ensures it covers the screen
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
              ),
            if (thumbnail != null || backgroundImage.isNotEmpty)
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 20,
                  sigmaY: 20,
                ), // ✅ Blur intensity
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.2,
                  ), // Optional overlay for contrast
                ),
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
                          DefaultTextStyle(
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                            child: IconTheme(
                              data: IconThemeData(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text('Phát từ'),
                                      Text('Danh sách phát A'),
                                      Text('-'),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: null,
                                    icon: Icon(Icons.more_vert),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          MusicDiscIllustrator(),
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
                                          audioHandler
                                                  .currentMediaItem
                                                  ?.artist ??
                                              '<Không rõ tác giả>',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                    ],
                                  ),
                                  Slider(
                                    value: min(
                                      position.inSeconds.toDouble(),
                                      duration.inSeconds.toDouble(),
                                    ),
                                    min: 0,
                                    max: duration.inSeconds.toDouble(),
                                    onChanged:
                                        (value) => audioHandler.seek(
                                          Duration(seconds: value.toInt()),
                                        ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatDuration(position.inSeconds),
                                        ),
                                        Text(
                                          formatDuration(
                                            audioHandler
                                                    .player
                                                    .duration
                                                    ?.inSeconds ??
                                                0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
      ),
    );
  }
}
