import 'package:flutter/material.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class MusicListControllerGroup extends StatelessWidget {
  const MusicListControllerGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    final musics = playerProvider.musics;
    Future<void> playNow({bool isShuffle = false}) async {
      await audioHandler.stop();
      await audioHandler.player.setShuffleModeEnabled(isShuffle);
      await audioHandler.setPlaylist([]);
      await audioHandler.setPlaylistFromMusics(musics);
      await audioHandler.playMediaItem(audioHandler.playlist.first);
      playerProvider.showMiniPlayer();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        SizedBox(
          width: 150,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: const Color.fromARGB(
                  255,
                  167,
                  167,
                  167,
                ).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            onPressed:
                musics.isNotEmpty
                    ? () async {
                      if (musics.first.path !=
                          audioHandler.currentMediaItem?.id) {
                        await playNow(isShuffle: false);
                      } else {
                        await audioHandler.seek(Duration.zero);
                      }
                    }
                    : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [Icon(Icons.play_arrow), Text('Phát nhạc')],
            ),
          ),
        ),
        SizedBox(
          width: 150,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: const Color.fromARGB(
                  255,
                  167,
                  167,
                  167,
                ).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            onPressed:
                musics.length > 1 ? () => playNow(isShuffle: true) : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [Icon(Icons.shuffle), Text('Ngẫu nhiên')],
            ),
          ),
        ),
      ],
    );
  }
}
