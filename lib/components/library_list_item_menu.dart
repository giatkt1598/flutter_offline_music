import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/create_edit_library_dialog.dart';
import 'package:flutter_offline_music/components/download_all_music_thumbnail_from_youtube.dart';
import 'package:flutter_offline_music/components/library_thumbnail.dart';
import 'package:flutter_offline_music/components/music_list_simple_info.dart';
import 'package:flutter_offline_music/components/show_confirm_dialog.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/pages/music_select_to_library_page.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';

class LibraryListItemMenu extends StatelessWidget {
  LibraryListItemMenu({
    super.key,
    required this.library,
    required this.onRefresh,
  });
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
        title: tr().deleteLibraryPopupTitle,
        message: tr().deleteLibraryPopUpMessage(library.title),
      );
      if (isConfirm != true) return;

      await libraryService.deleteAsync(library.id);
      ToastService.showSuccess(tr().deleteLibrarySuccess(library.title));
      Navigator.of(context).pop();
      onRefresh();
    }

    Future<void> getThumbnails(BuildContext context) async {
      Navigator.pop(context);
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return DownloadAllMusicThumbnailFromYoutube(musics: library.musics);
        },
      );
    }

    return SizedBox(
      height: 500,
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
          Text(library.title, style: TextStyle(fontWeight: FontWeight.bold)),
          Opacity(
            opacity: 0.4,
            child: MusicListSimpleInfo(
              musics: library.musics,
              style: TextStyle(fontSize: 12),
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
            title: Text(tr().libraryMenu_addItem),
          ),
          ListTile(
            enabled: true,
            onTap: () {
              Navigator.pop(context);
              showDialogCreateUpdateLibrary(
                context,
                libraryIdForUpdate: library.id,
                whenDone: (_) => onRefresh(),
              );
            },
            leading: Icon(Icons.edit),
            title: Text(tr().libraryMenu_edit),
          ),
          ListTile(
            enabled: false,
            onTap: null,
            leading: Icon(Icons.sort_rounded),
            title: Text(tr().libraryMenu_sortItems),
          ),
          ListTile(
            onTap: () => getThumbnails(context),
            leading: Icon(Icons.image),
            title: Text(tr().libraryMenu_downloadItemThumbnails),
          ),
          ListTile(
            onTap: () => deleteLibrary(context),
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text(
              tr().libraryMenu_deleteLibrary,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
