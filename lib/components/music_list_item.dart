import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/auto_scroll_text.dart';
import 'package:flutter_offline_music/components/music_item_menu.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class MusicListItem extends StatelessWidget {
  const MusicListItem({super.key, required this.music, this.afterHideItem});
  final Music music;
  final Function? afterHideItem;
  @override
  Widget build(BuildContext context) {
    final audioHandler = Provider.of<PlayerProvider>(context).audioHandler;

    void playMusic() {
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

    final isCurrent = audioHandler.currentMediaItem?.id == music.path;

    return Container(
      decoration:
          isCurrent
              ? BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 5,
                  ),
                ),
              )
              : null,
      child: ListTile(
        contentPadding: EdgeInsets.only(right: 0, left: 8),
        horizontalTitleGap: 0,
        tileColor:
            isCurrent
                ? Theme.of(
                  context,
                ).colorScheme.inversePrimary.withValues(alpha: 0.3)
                : null,
        onTap: playMusic,
        leading: Opacity(
          opacity: music.isHidden ? 0.3 : 1,
          child: MusicThumbnail(musicPath: music.path),
        ),
        trailing: MusicItemMenu(music: music, afterToggleHide: afterHideItem),
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 4,
                children: [
                  if (isCurrent)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Image.asset('assets/playing.gif'),
                    ),
                  Expanded(
                    child:
                        isCurrent
                            ? AutoScrollText(
                              // useDebug: true,
                              text: music.title,
                              containerWidth:
                                  MediaQuery.of(context).size.width - 120,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                            : Text(
                              music.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (music.isHidden)
                    Text(
                      '(Bị ẩn) ',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  Expanded(
                    child: Opacity(
                      opacity: 0.4,
                      child: Text(
                        music.artist ?? '<Không rõ tác giả>',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isCurrent
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
