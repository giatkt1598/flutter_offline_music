import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/library_list_item_menu_button.dart';
import 'package:flutter_offline_music/components/music_item_menu.dart';
import 'package:flutter_offline_music/components/music_list.dart';
import 'package:flutter_offline_music/components/music_list_controller_group.dart';
import 'package:flutter_offline_music/components/music_list_simple_info.dart';
import 'package:flutter_offline_music/components/no_data.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/pages/music_select_to_library_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:provider/provider.dart';

class MusicListInLibraryPage extends StatefulWidget {
  final int libraryId;

  const MusicListInLibraryPage({super.key, required this.libraryId});
  @override
  State<MusicListInLibraryPage> createState() => _MusicListInLibraryPageState();
}

class _MusicListInLibraryPageState extends State<MusicListInLibraryPage> {
  final LibraryService libraryService = LibraryService();
  final MusicService musicService = MusicService();
  late Library library;
  bool loaded = false;

  void addMusicToLibrary() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) => MusicSelectToLibraryPage(libraryId: library.id),
          ),
        )
        .then((_) => loadLibrary());
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) return Container();

    final playerProvider = Provider.of<PlayerProvider>(context);
    final musics = playerProvider.musics;

    return Scaffold(
      appBar: AppBar(
        title: Text(library.title),
        actions: [
          LibraryListItemMenuButton(library: library, onRefresh: loadLibrary),
        ],
        shadowColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: MusicListSimpleInfo(musics: musics),
                    ),
                    IconButton(
                      onPressed: addMusicToLibrary,
                      icon: Icon(Icons.library_add),
                    ),
                  ],
                ),
                MusicListControllerGroup(),
              ],
            ),
          ),
          if (musics.isEmpty)
            Expanded(
              child: Column(
                children: [
                  NoData(title: tr().emptyList),
                  ElevatedButton(
                    onPressed: addMusicToLibrary,
                    child: Text(tr().addSongsToLibrary),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: MusicList(
                menuType: MusicMenuType.inLibrary,
                musics: musics,
                onChanged: (value) => loadLibrary(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    loadLibrary();
    super.initState();
  }

  Future<Library> loadLibrary() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.currentLibraryId = widget.libraryId;
    var libs = await libraryService.getListAsync(id: widget.libraryId);
    setState(() {
      library = libs.first;
    });
    playerProvider.setMusics(library.musics);
    setState(() {
      loaded = true;
    });
    return library;
  }
}
