import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/auto_scroll_text.dart';
import 'package:flutter_offline_music/components/highlighted_text.dart';
import 'package:flutter_offline_music/components/music_item_menu.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class MusicListItem extends StatelessWidget {
  const MusicListItem({
    super.key,
    required this.music,
    this.afterHideItem,
    this.keywordSearch,
    this.onTap,
    this.trailing,
    this.leading,
    this.musicTitleColor,
    this.iconColor,
    this.musicArtistColor,
    this.activeMusicTitleColor,
    this.tileColor,
    this.menuType = MusicMenuType.inMusicList,
    this.showMiniPlayer = true,
    this.afterToggleFavorite,
  });

  final Music music;
  final Function? afterHideItem;
  final Function? afterToggleFavorite;
  final String? keywordSearch;
  final void Function()? onTap;
  final Widget? trailing;
  final Widget? leading;
  final Color? musicTitleColor;
  final Color? iconColor;
  final Color? musicArtistColor;
  final Color? activeMusicTitleColor;
  final Color? tileColor;
  final MusicMenuType menuType;
  final bool showMiniPlayer;
  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;

    final isCurrent = audioHandler.currentMediaItem?.id == music.path;
    final artist = music.artist ?? '<Không rõ tác giả>';
    final TextStyle artistTextStyle = TextStyle(
      fontSize: 12,
      color: musicArtistColor,
    );
    final double borderWidth = 5.0;
    return Container(
      decoration:
          isCurrent
              ? BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: borderWidth,
                  ),
                ),
              )
              : null,
      child: ListTile(
        contentPadding: EdgeInsets.only(
          right: 0,
          left: 8 - (isCurrent ? borderWidth : 0),
        ),
        horizontalTitleGap: 0,
        tileColor:
            tileColor ??
            (isCurrent
                ? Theme.of(
                  context,
                ).colorScheme.inversePrimary.withValues(alpha: 0.3)
                : null),
        onTap:
            onTap ??
            () => playerProvider.openAudioPlayerPage(context, music: music),
        leading:
            leading ??
            Opacity(
              opacity: music.isHidden ? 0.3 : 1,
              child: MusicThumbnail(musicPath: music.path),
            ),
        trailing:
            trailing ??
            MusicItemMenu(
              music: music,
              afterToggleHide: afterHideItem,
              type: menuType,
              showMiniPlayer: showMiniPlayer,
              afterToggleFavorite: afterToggleFavorite,
            ),
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 4,
                children: [
                  if (isCurrent && audioHandler.playing)
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
                                color:
                                    activeMusicTitleColor ??
                                    Theme.of(context).colorScheme.primary,
                              ),
                            )
                            : keywordSearch != null
                            ? HighlightedText(
                              fullText: music.title,
                              highlightedText: keywordSearch!,
                            )
                            : Text(
                              music.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: musicTitleColor),
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
                      child:
                          keywordSearch != null
                              ? HighlightedText(
                                fullText: artist,
                                highlightedText: keywordSearch!,
                                style: artistTextStyle,
                              )
                              : Text(
                                artist,
                                style: artistTextStyle,
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
