import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/highlighted_text.dart';
import 'package:flutter_offline_music/components/library_list_item_menu_button.dart';
import 'package:flutter_offline_music/components/library_thumbnail.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/pages/music_list_in_library_page.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:flutter_offline_music/services/music_service.dart';

class LibraryListItem extends StatelessWidget {
  LibraryListItem({
    super.key,
    required this.library,
    required this.onRefresh,
    this.keywordSearch,
  });
  final musicService = MusicService();
  final libraryService = LibraryService();
  final Library library;
  final Function onRefresh;
  final String? keywordSearch;
  @override
  Widget build(BuildContext context) {
    openMusicList() {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => MusicListInLibraryPage(libraryId: library.id),
            ),
          )
          .then((_) => onRefresh());
    }

    return ListTile(
      onTap: openMusicList,
      contentPadding: EdgeInsets.only(left: 16, right: 4),
      leading: LibraryThumbnail(library: library),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          keywordSearch != null
              ? HighlightedText(
                fullText: library.title,
                highlightedText: keywordSearch!,
                style: TextStyle(fontWeight: FontWeight.normal),
              )
              : Text(
                library.title,
                style: TextStyle(fontWeight: FontWeight.normal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

          Opacity(
            opacity: 0.4,
            child: Text(
              tr().nSongs(library.musics.length),
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: LibraryListItemMenuButton(
        library: library,
        onRefresh: onRefresh,
      ),
    );
  }
}
