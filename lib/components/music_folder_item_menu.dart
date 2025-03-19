import 'dart:math';

import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_offline_music/components/menu_popover.dart';
import 'package:flutter_offline_music/components/music_folder_info.dart';
import 'package:flutter_offline_music/components/show_confirm_dialog.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:provider/provider.dart';

class MusicFolderItemMenu extends StatefulWidget {
  const MusicFolderItemMenu({
    super.key,
    required this.musicFolder,
    required this.onRefresh,
    required this.afterHideFolder,
  });
  final MusicFolder musicFolder;
  final Function onRefresh;
  final Function afterHideFolder;

  @override
  State<MusicFolderItemMenu> createState() => _MusicFolderItemMenuState();
}

class _MusicFolderItemMenuState extends State<MusicFolderItemMenu> {
  final MusicService _musicService = MusicService();
  final LibraryService _libraryService = LibraryService();
  int get totalHiddenFile =>
      widget.musicFolder.musics.where((x) => x.isHidden).length;

  @override
  Widget build(BuildContext context) {
    bool hasHiddenFile = totalHiddenFile > 0;

    hideFolder() async {
      widget.musicFolder.isHidden = !widget.musicFolder.isHidden;
      await _musicService.updateMusicFolderAsync(widget.musicFolder);
      widget.afterHideFolder();
    }

    toggleHiddenAllFile() async {
      for (var music in widget.musicFolder.musics) {
        music.isHidden = !hasHiddenFile;
        await _musicService.updateMusicAsync(music);
      }
      widget.onRefresh();
    }

    Future<void> createLibraryFromFolder() async {
      var allLibraries = await _libraryService.getListAsync();
      var existedLibrary = allLibraries.firstWhereOrDefault(
        (x) => x.title.toLowerCase() == widget.musicFolder.name.toLowerCase(),
      );

      addMusicToLibrary(int libraryId) async {
        EasyLoading.show(
          maskType: EasyLoadingMaskType.black,
          status: tr().status_waiting,
          dismissOnTap: false,
        );
        for (var music in widget.musicFolder.musics.where((x) => !x.isHidden)) {
          await _libraryService.addMusicToLibraryAsync(
            musicId: music.id,
            libraryId: libraryId,
          );
        }
        EasyLoading.dismiss();
      }

      if (existedLibrary != null) {
        bool? isAddMusicToExistedLibrary = await showConfirmDialog(
          context: context,
          message: tr().folderMenu_createLibraryDuplicatedMessage,
        );

        if (isAddMusicToExistedLibrary == true) {
          await addMusicToLibrary(existedLibrary.id);
          ToastService.showSuccess(tr().status_completed);
        }
      } else {
        int newLibId = await _libraryService.insertAsync(
          Library(
            id: 0,
            title: widget.musicFolder.name.substring(
              0,
              min(widget.musicFolder.name.length, 50),
            ),
            creationTime: DateTime.now(),
          ),
        );
        await addMusicToLibrary(newLibId);
        ToastService.showSuccess(
          tr().folderMenu_createLibrarySuccess(widget.musicFolder.name),
        );
      }
    }

    showFolderInfo() async {
      final playerProvider = Provider.of<PlayerProvider>(
        context,
        listen: false,
      );
      playerProvider.hideMiniPlayer();

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr().detailTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Opacity(opacity: 0.3, child: Divider()),
                  MusicFolderInfo(folder: widget.musicFolder),
                ],
              ),
            ),
          );
        },
      );
      playerProvider.showMiniPlayer();
    }

    return MenuPopover<String>(
      onPopoverResult: (result) async {
        if (result == 'create_library') {
          await createLibraryFromFolder();
        } else if (result == 'hide') {
          await hideFolder();
        } else if (result == 'info') {
          await showFolderInfo();
        } else if (result == 'toggle_hidden_all_file') {
          await toggleHiddenAllFile();
        }
      },
      options: [
        PopupMenuItem(
          value: 'create_library',
          child: ListTile(
            leading: Icon(Icons.playlist_add),
            title: Text(tr().createLibraryTitle),
          ),
        ),
        PopupMenuItem(
          value: 'info',
          child: ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text(tr().detailTitle),
          ),
        ),
        PopupMenuItem(
          value: 'hide',
          child: ListTile(
            leading:
                widget.musicFolder.isHidden
                    ? Icon(Icons.folder)
                    : Icon(Icons.folder_off_outlined),
            title: Text(
              widget.musicFolder.isHidden
                  ? tr().folderMenu_displayFolder
                  : tr().folderMenu_hideFolder,
            ),
          ),
        ),
        if (widget.musicFolder.musics.isNotEmpty)
          PopupMenuItem(
            value: 'toggle_hidden_all_file',
            child:
                hasHiddenFile
                    ? ListTile(
                      leading: Icon(Icons.music_note_outlined),
                      title: Text(
                        tr().folderMenu_displayAllFiles(totalHiddenFile),
                      ),
                    )
                    : ListTile(
                      leading: Icon(Icons.music_off_outlined),
                      title: Text(tr().folderMenu_hideAllFiles),
                    ),
          ),
      ],
      trigger:
          (show) => IconButton(onPressed: show, icon: Icon(Icons.more_vert)),
    );
  }
}
