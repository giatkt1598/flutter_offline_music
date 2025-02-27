import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/hidden_music_folder_info.dart';
import 'package:flutter_offline_music/components/menu_popover.dart';
import 'package:flutter_offline_music/components/music_list.dart';
import 'package:flutter_offline_music/components/song_list_item.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:flutter_offline_music/providers/music_folder_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:provider/provider.dart';

class MusicInFolderPage extends StatefulWidget {
  const MusicInFolderPage({super.key, required this.musicFolder});

  final MusicFolder musicFolder;

  @override
  State<MusicInFolderPage> createState() => _MusicInFolderPageState();
}

class _MusicInFolderPageState extends State<MusicInFolderPage> {
  final MusicService musicService = MusicService();
  int get totalHiddenFile =>
      widget.musicFolder.musics.where((x) => x.isHidden).length;
  @override
  Widget build(BuildContext context) {
    final musicFolderProvider = Provider.of<MusicFolderProvider>(context);
    bool hasHiddenFile = totalHiddenFile > 0;
    final currentMusics =
        musicFolderProvider.isShowAllMusicFolder
            ? widget.musicFolder.musics
            : widget.musicFolder.musics.where((x) => !x.isHidden).toList();

    hideFolder() async {
      widget.musicFolder.isHidden = !widget.musicFolder.isHidden;
      await musicService.updateMusicFolderAsync(widget.musicFolder);
      Navigator.of(context).pop();
    }

    toggleHiddenAllFile() async {
      for (var music in widget.musicFolder.musics) {
        music.isHidden = !hasHiddenFile;
        await musicService.updateMusicAsync(music);
      }
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.musicFolder.name),
            Row(
              children: [
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    '(${currentMusics.length} bài hát)',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                if (widget.musicFolder.isHidden)
                  Text(' | ', style: TextStyle(fontSize: 12)),
                if (widget.musicFolder.isHidden)
                  Text(
                    'Thư mục ẩn',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          MenuPopover<String>(
            onPopoverResult: (result) async {
              if (result == 'create_playlist') {
                //TODO:
              } else if (result == 'hide') {
                await hideFolder();
              } else if (result == 'info') {
                //TODO:
              } else if (result == 'toggle_hidden_all_file') {
                await toggleHiddenAllFile();
              }
            },
            options: [
              PopupMenuItem(
                value: 'create_playlist',
                child: ListTile(
                  leading: Icon(Icons.playlist_add),
                  title: Text('Tạo thư viện'),
                ),
              ),
              PopupMenuItem(
                value: 'info',
                child: ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('Chi tiết'),
                ),
              ),
              PopupMenuItem(
                value: 'hide',
                child: ListTile(
                  leading:
                      widget.musicFolder.isHidden
                          ? Icon(Icons.visibility_rounded)
                          : Icon(Icons.visibility_off_rounded),
                  title: Text(
                    widget.musicFolder.isHidden
                        ? 'Hiển thị thư mục'
                        : 'Ẩn thư mục',
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
                              'Hiển thị tất cả tệp ($totalHiddenFile tệp)',
                            ),
                          )
                          : ListTile(
                            leading: Icon(Icons.music_off_outlined),
                            title: Text('Ẩn tất cả tệp'),
                          ),
                ),
            ],
            trigger:
                (show) =>
                    IconButton(onPressed: show, icon: Icon(Icons.more_vert)),
          ),
        ],
      ),
      body: MusicList(
        removeInvisibleItem: !musicFolderProvider.isShowAllMusicFolder,
        musics: currentMusics,
        onChanged: (value) => setState(() {}),
        trailingItem:
            totalHiddenFile < 1
                ? null
                : HiddenMusicFolderInfo(totalHiddenFile: totalHiddenFile),
      ),
    );
  }
}
