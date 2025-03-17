import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/auto_scroll_text.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/components/rotating_disc.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatefulWidget {
  static OverlayEntry? _overlayEntry;
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();

  static void showMiniPlayer(BuildContext? context) {
    if (_overlayEntry != null || context == null) return;
    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(bottom: 12, left: 6, child: MiniPlayer()),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}

class _MiniPlayerState extends State<MiniPlayer> {
  final musicService = MusicService();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late StreamSubscription<Duration?> durationSubscription;
  late StreamSubscription<Duration?> positionSubscription;
  final GlobalKey _sliderParentKey = GlobalKey();
  double? sliderMaxWidth;
  double? sliderWidth;
  @override
  void initState() {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final audioHandler = playerProvider.audioHandler;
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
          if (sliderMaxWidth == null) {
            if (_sliderParentKey.currentContext != null) {
              final RenderBox renderBox =
                  _sliderParentKey.currentContext!.findRenderObject()
                      as RenderBox;
              var rowWidth = renderBox.size.width;
              sliderMaxWidth = rowWidth;
            }
          }

          if (sliderMaxWidth != null && duration > Duration.zero) {
            sliderWidth =
                position.inSeconds / duration.inSeconds * sliderMaxWidth!;
          }
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

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;

    if (!playerProvider.isShowMiniPlayer ||
        audioHandler.currentMediaItem == null) {
      return Container();
    }

    final mediaItem = audioHandler.currentMediaItem!;

    openPlayerPage() async {
      var music = await musicService.getMusicAsync(path: mediaItem.id);
      playerProvider.openAudioPlayerPage(context, music: music);
    }

    bool hasThumbnail = audioHandler.currentMediaItem?.artUri != null;
    return Container(
      width: MediaQuery.of(context).size.width - 12,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
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

      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        child: Column(
          key: _sliderParentKey,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 4,
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        playerProvider.hideMiniPlayer();
                      },
                      onTap: openPlayerPage,
                      child:
                          hasThumbnail
                              ? MusicThumbnail(
                                thumbnailPath: mediaItem.artUri?.toFilePath(),
                                size: 50,
                                boxShape: BoxShape.rectangle,
                              )
                              : SizedBox(
                                height: 60,
                                width: 60,
                                child: RotatingDisc(),
                              ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () {
                          playerProvider.hideMiniPlayer();
                        },
                        onTap: openPlayerPage,
                        child: Container(
                          height: 50,
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              AutoScrollText(
                                text: mediaItem.title,
                                containerWidth:
                                    MediaQuery.of(context).size.width - 100,
                              ),
                              Opacity(
                                opacity: 0.4,
                                child: AutoScrollText(
                                  text:
                                      mediaItem.artist ?? '<Không rõ tác giả>',
                                  style: TextStyle(fontSize: 12),
                                  containerWidth:
                                      MediaQuery.of(context).size.width - 100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(255, 240, 240, 240),
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
                          audioHandler.playing ? Icons.pause : Icons.play_arrow,
                          size: 40,
                        ),
                      ),
                    ),

                    // IconButton(
                    //   onPressed: () {},
                    //   icon: Icon(Icons.skip_next_rounded, size: 40),
                    // ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: sliderWidth,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
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
