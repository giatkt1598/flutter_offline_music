import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/auto_scroll_text.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/pages/player_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();

  static void showMiniPlayer(BuildContext context) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(bottom: 12, left: 6, child: MiniPlayer()),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}

class _MiniPlayerState extends State<MiniPlayer> {
  final musicService = MusicService();

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
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  PlayerPage(music: music),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
                  SlideTransition(
                    position: Tween(
                      begin: Offset(0, 1),
                      end: Offset(0, 0),
                    ).animate(animation),
                    child: child,
                  ),
        ),
      );
    }

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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            GestureDetector(
              onTap: openPlayerPage,
              child: MusicThumbnail(
                musicPath: mediaItem.id,
                size: 50,
                boxShape: BoxShape.rectangle,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: openPlayerPage,
                child: Container(
                  height: 50,
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      AutoScrollText(text: mediaItem.title),
                      Opacity(
                        opacity: 0.4,
                        child: AutoScrollText(
                          text: mediaItem.artist ?? '<Không rõ tác giả>',
                          style: TextStyle(fontSize: 12),
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
    );
  }
}
