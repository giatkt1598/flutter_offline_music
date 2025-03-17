import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_pages/player_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

@Deprecated('Use MusicListItem widget for instead')
class SongListItem extends StatelessWidget {
  const SongListItem({super.key, required this.music});

  final Music music;

  @override
  Widget build(BuildContext context) {
    final audioHandler = Provider.of<PlayerProvider>(context).audioHandler;
    bool isCurrent =
        audioHandler.currentMediaItem?.id == music.path && audioHandler.playing;
    void onPressed() {
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

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 2, bottom: 6),
      child: Container(
        color: isCurrent ? const Color.fromARGB(66, 221, 221, 221) : null,
        child: Row(
          spacing: 4,
          children: [
            GestureDetector(
              onTap: onPressed,
              child: MusicThumbnail(thumbnailPath: music.thumbnail),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onPressed,
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        music.title,
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Opacity(
                        opacity: 0.4,
                        child: Text(
                          music.artist ?? '<Không rõ tác giả>',
                          style: TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_outlined)),
          ],
        ),
      ),
    );
  }
}
