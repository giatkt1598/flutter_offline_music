import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/auto_scroll_text.dart';
import 'package:flutter_offline_music/components/rotating_disc.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/foreground_service.dart';
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
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    if (widget.music.id != playerProvider.music?.id) {
      playerProvider.stopAsync().then((_) {
        playerProvider.setMusic(widget.music);
        playerProvider.play();
      });
    }
    MusicForegroundService.startService(context)
        .then((onValue) {
          print('[cus]done1');
        })
        .onError((e, st) {
          print('[cus]has err');
        });

    super.initState();
  }

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
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
                              text: playerProvider.music?.name ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Opacity(
                              opacity: 0.4,
                              child: Text(
                                playerProvider.music?.author ??
                                    '<Không rõ tác giả>',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                        Slider(
                          value: playerProvider.position.inSeconds.toDouble(),
                          min: 0,
                          max: playerProvider.duration.inSeconds.toDouble(),
                          onChanged: playerProvider.seek,
                          padding: EdgeInsets.zero,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDuration(playerProvider.position.inSeconds),
                            ),
                            Text(
                              formatDuration(
                                playerProvider.player.duration?.inSeconds ?? 0,
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
                          onPressed: null,
                          icon: Icon(Icons.shuffle_sharp, color: Colors.black),
                        ),
                        IconButton(
                          onPressed:
                              playerProvider.canPrevious
                                  ? playerProvider.previous
                                  : null,
                          icon: Icon(Icons.skip_previous_rounded),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ), // 👈 Viền đen
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (playerProvider.isPlaying) {
                                playerProvider.pause();
                              } else {
                                playerProvider.play();
                              }
                            },
                            icon: Icon(
                              playerProvider.player.playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            iconSize: 50,
                            style: ButtonStyle(),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              playerProvider.canNext
                                  ? playerProvider.next
                                  : null,
                          icon: Icon(Icons.skip_next_rounded),
                        ),
                        IconButton(
                          onPressed: null,
                          icon: Icon(Icons.loop_rounded),
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
