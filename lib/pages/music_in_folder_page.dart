import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/hidden_music_folder_info.dart';
import 'package:flutter_offline_music/components/music_folder_item_menu.dart';
import 'package:flutter_offline_music/components/music_list.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:flutter_offline_music/providers/music_folder_provider.dart';
import 'package:provider/provider.dart';

class MusicInFolderPage extends StatefulWidget {
  const MusicInFolderPage({super.key, required this.musicFolder});

  final MusicFolder musicFolder;

  @override
  State<MusicInFolderPage> createState() => _MusicInFolderPageState();
}

class _MusicInFolderPageState extends State<MusicInFolderPage> {
  int get totalHiddenFile =>
      widget.musicFolder.musics.where((x) => x.isHidden).length;
  @override
  Widget build(BuildContext context) {
    final musicFolderProvider = Provider.of<MusicFolderProvider>(context);
    final currentMusics =
        musicFolderProvider.isShowAllMusicFolder
            ? widget.musicFolder.musics
            : widget.musicFolder.musics.where((x) => !x.isHidden).toList();

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
          MusicFolderItemMenu(
            musicFolder: widget.musicFolder,
            onRefresh: () => setState(() {}),
            afterHideFolder: () => Navigator.of(context).pop(),
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
