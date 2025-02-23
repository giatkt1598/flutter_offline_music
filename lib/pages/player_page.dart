import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/auto_scroll_text.dart';
import 'package:flutter_offline_music/components/rotating_disc.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.music});

  final Music music;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  @override
  void initState() {
    final audioHandler =
        Provider.of<PlayerProvider>(context, listen: false).audioHandler;
    if (widget.music.path != audioHandler.currentMediaItem?.id) {
      audioHandler.stop().then((_) {
        audioHandler.playMusic(widget.music);
      });
    }
    super.initState();
  }

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final audioHandler = Provider.of<PlayerProvider>(context).audioHandler;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                    IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
                  ],
                ),
                RotatingDisc(),
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
                              text: audioHandler.currentMediaItem?.title ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Opacity(
                              opacity: 0.4,
                              child: Text(
                                audioHandler.currentMediaItem?.artist ??
                                    '<Không rõ tác giả>',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                        Slider(
                          value: min(
                            audioHandler.position.inSeconds.toDouble(),
                            audioHandler.duration.inSeconds.toDouble(),
                          ),
                          min: 0,
                          max: audioHandler.duration.inSeconds.toDouble(),
                          onChanged:
                              (value) => audioHandler.seek(
                                Duration(seconds: value.toInt()),
                              ),
                          padding: EdgeInsets.zero,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDuration(audioHandler.position.inSeconds),
                            ),
                            Text(
                              formatDuration(
                                audioHandler.player.duration?.inSeconds ?? 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            audioHandler.setShuffle(!audioHandler.isShuffle);
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
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2,
                            ), // 👈 Viền đen
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (audioHandler.player.playing) {
                                audioHandler.pause();
                              } else {
                                audioHandler.play();
                              }
                            },
                            icon: Icon(
                              audioHandler.player.playing
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
                                audioHandler.player.setLoopMode(LoopMode.all);
                                break;
                              case LoopMode.all:
                                audioHandler.player.setLoopMode(LoopMode.one);
                                break;
                              default:
                                audioHandler.player.setLoopMode(LoopMode.off);
                                break;
                            }
                          },
                          icon:
                              audioHandler.player.loopMode == LoopMode.all
                                  ? Icon(Icons.repeat_rounded)
                                  : audioHandler.player.loopMode == LoopMode.one
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
