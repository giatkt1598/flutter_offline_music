import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/audio_slider.dart';
import 'package:flutter_offline_music/components/auto_scroll_text.dart';
import 'package:flutter_offline_music/components/countdown.dart';
import 'package:flutter_offline_music/components/music_disc_illustrator.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class PlayerAudioTabContent extends StatefulWidget {
  const PlayerAudioTabContent({super.key, required this.music});

  final Music music;

  @override
  State<PlayerAudioTabContent> createState() => _PlayerAudioTabContentState();
}

class _PlayerAudioTabContentState extends State<PlayerAudioTabContent>
    with AutomaticKeepAliveClientMixin {
  Duration position = Duration.zero;
  late StreamSubscription<Duration?> positionSubscription;
  final musicService = MusicService();
  @override
  void initState() {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final audioHandler = playerProvider.audioHandler;
    playerProvider.isShowMiniPlayer = false;

    Future play() async {
      if (audioHandler.playlist.isEmpty) {
        await audioHandler.setPlaylistFromMusics(playerProvider.musics);
      }

      if (widget.music.path != audioHandler.currentMediaItem?.id) {
        await audioHandler.stop();
        await audioHandler.playMusic(widget.music);
      }
    }

    play();

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
    super.build(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    final duration = audioHandler.currentMediaItem?.duration ?? Duration.zero;
    final currentPosition =
        audioHandler.playingMediaItemId == audioHandler.currentMediaItem?.id
            ? position
            : Duration.zero;
    final music = audioHandler.currentMusic ?? widget.music;
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
                          Text('Dừng sau '),
                          Countdown(endTime: audioHandler.stopTime),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () {
                      music.isFavorite = !music.isFavorite;
                      musicService.updateMusicAsync(music);

                      //TODO: refactor
                      final musicInList =
                          playerProvider.musics
                              .where((x) => x.id == music.id)
                              .firstOrNull;

                      if (musicInList != null) {
                        musicInList.isFavorite = music.isFavorite;
                      }

                      final musicInPlaylist =
                          playerProvider.audioHandler.musics
                              .where((x) => x.id == music.id)
                              .firstOrNull;
                      if (musicInPlaylist != null) {
                        musicInPlaylist.isFavorite = music.isFavorite;
                        playerProvider.notifyChanges();
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          Center(child: MusicDiscIllustrator(music: music)),
                          if (music.isFavorite == true)
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
                            // Text(
                            //   playerProvider.music?.name ?? '',
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 20,
                            //   ),
                            // ),
                            AutoScrollText(
                              isCenter: true,
                              text: audioHandler.currentMediaItem?.title ?? '',
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: AudioSlider(
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
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                fDurationHHMMSS(currentPosition, short: true),
                              ),
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
                                audioHandler.setLoopMode(LoopMode.all);
                                break;
                              case LoopMode.all:
                                audioHandler.setLoopMode(LoopMode.one);
                                break;
                              default:
                                audioHandler.setLoopMode(LoopMode.off);
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

  @override
  bool get wantKeepAlive => true;
}
