import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/library_thumbnail.dart';
import 'package:flutter_offline_music/components/show_confirm_dialog.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/pages/music_list_in_library_page.dart';
import 'package:flutter_offline_music/pages/music_select_to_library_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:provider/provider.dart';

class LibraryListItem extends StatelessWidget {
  LibraryListItem({super.key, required this.library, required this.onRefresh});
  final musicService = MusicService();
  final libraryService = LibraryService();
  final Library library;
  final Function onRefresh;

  @override
  Widget build(BuildContext context) {
    addMusicToLibrary() {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder:
                  (context) => MusicSelectToLibraryPage(libraryId: library.id),
            ),
          )
          .then((_) => onRefresh());
    }

    deleteLibrary(BuildContext context) async {
      var isConfirm = await showConfirmDialog(
        context: context,
        title: 'Xóa thư viện',
        message: 'Bạn chắc chắn muốn xóa thư viện ${library.title}?',
      );
      if (isConfirm != true) return;

      await libraryService.deleteAsync(library.id);
      Navigator.of(context).pop();
      onRefresh();
    }

    showMenuOption() async {
      final playerProvider = Provider.of<PlayerProvider>(
        context,
        listen: false,
      );
      playerProvider.hideMiniPlayer();
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 400,
            child: Column(
              children: [
                SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Center(
                    child: Transform.scale(
                      scale: 2,
                      child: LibraryThumbnail(library: library),
                    ),
                  ),
                ),
                Text(
                  library.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    '${library.musics.length} bài hát ・ ${musicService.calcTotalDuration(library.musics)}',
                    style: TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    addMusicToLibrary();
                  },
                  leading: Icon(Icons.playlist_add),
                  title: Text('Thêm bài hát vào thư viện'),
                ),
                ListTile(
                  enabled: false,
                  onTap: () {},
                  leading: Icon(Icons.edit),
                  title: Text('Đổi tên'),
                ),
                ListTile(
                  onTap: () => deleteLibrary(context),
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Xóa thư viện',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      ).then((_) => playerProvider.showMiniPlayer());
    }

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
          Text(
            library.title,
            style: TextStyle(fontWeight: FontWeight.normal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          Opacity(
            opacity: 0.4,
            child: Text(
              '${library.musics.length} bài hát',
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: showMenuOption,
        icon: Icon(Icons.more_vert),
      ),
    );
  }
}
