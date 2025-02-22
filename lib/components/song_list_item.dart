import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class SongListItem extends StatelessWidget {
  const SongListItem({super.key, required this.music});

  final Music music;

  @override
  Widget build(BuildContext context) {
    final audioHandler = Provider.of<PlayerProvider>(context).audioHandler;
    bool isCurrent =
        audioHandler.currentMediaItem?.id == music.path &&
        audioHandler.player.playing;
    void onPressed() {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => PlayerPage()),
      // );

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
              child: SizedBox(
                width: 40,
                height: 40,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child:
                      isCurrent
                          ? Image.asset(
                            'assets/music.gif',
                            width: 20,
                            height: 20,
                          )
                          : Icon(Icons.music_note_rounded),
                ),
              ),
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
                        music.name,
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
                          music.author ?? '<Không rõ tác giả>',
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
