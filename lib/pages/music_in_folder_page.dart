import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/hidden_music_folder_info.dart';
import 'package:flutter_offline_music/components/music_folder_item_menu.dart';
import 'package:flutter_offline_music/components/music_list.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
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
  late MusicFolder musicFolder;
  final service = MusicService();

  @override
  void initState() {
    musicFolder = widget.musicFolder;
    super.initState();
  }

  Future<void> fetchData() async {
    final list = await service.getMusicFolderListAsync(isHidden: null);
    setState(() {
      musicFolder = list.firstWhere((x) => x.id == musicFolder.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final musicFolderProvider = Provider.of<MusicFolderProvider>(context);
    var currentMusics =
        musicFolderProvider.isShowAllMusicFolder
            ? musicFolder.musics
            : musicFolder.musics.where((x) => !x.isHidden).toList();
    int totalHiddenFile = musicFolder.musics.where((x) => x.isHidden).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(musicFolder.name),
            Row(
              children: [
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    '(${tr().nSongs(currentMusics.length)})',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                if (musicFolder.isHidden)
                  Text(' | ', style: TextStyle(fontSize: 12)),
                if (musicFolder.isHidden)
                  Text(
                    tr().hiddenFolder,
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          MusicFolderItemMenu(
            musicFolder: musicFolder,
            onRefresh: fetchData,
            afterHideFolder: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: MusicList(
        removeInvisibleItem: !musicFolderProvider.isShowAllMusicFolder,
        musics: currentMusics,
        onChanged: (value) => fetchData(),
        trailingItem:
            totalHiddenFile < 1
                ? null
                : HiddenMusicFolderInfo(totalHiddenFile: totalHiddenFile),
      ),
    );
  }
}
