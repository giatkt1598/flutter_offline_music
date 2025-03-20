import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/library_thumbnail.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/pages/music_list_in_library_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

@Deprecated('In progress...')
class LibraryCardItem extends StatelessWidget {
  const LibraryCardItem({
    super.key,
    required this.library,
    required this.onRefresh,
  });
  final Library library;
  final Function onRefresh;

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    const double paddingLeft = 16.0;
    openMusicList() {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => MusicListInLibraryPage(libraryId: library.id),
            ),
          )
          .then((_) => onRefresh());
    }

    play() async {
      await audioHandler.stop();
      await audioHandler.setPlaylistFromMusics([]);
      await audioHandler.setPlaylistFromMusics(library.musics);
      await audioHandler.playMediaItem(audioHandler.playlist.first);
      playerProvider.showMiniPlayer();
    }

    return GestureDetector(
      onTap: openMusicList,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: paddingLeft,
                    top: paddingLeft,
                  ),
                  child: LibraryThumbnail(library: library, size: 80),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: paddingLeft, top: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      library.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                left: paddingLeft,
                right: 8,
                bottom: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Opacity(
                      opacity: 0.4,
                      child: Text(
                        tr().nSongs(library.musics.length),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: library.musics.isNotEmpty ? play : () {},
                    child: Opacity(
                      opacity: library.musics.isEmpty ? 0.4 : 1,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
