import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/library_list_item_menu_button.dart';
import 'package:flutter_offline_music/components/music_list.dart';
import 'package:flutter_offline_music/components/no_data.dart';
import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/pages/music_select_to_library_page.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/library_service.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:provider/provider.dart';

class MusicListInLibraryPage extends StatefulWidget {
  const MusicListInLibraryPage({super.key, required this.libraryId});

  final int libraryId;
  @override
  State<MusicListInLibraryPage> createState() => _MusicListInLibraryPageState();
}

class _MusicListInLibraryPageState extends State<MusicListInLibraryPage> {
  final LibraryService libraryService = LibraryService();
  final MusicService musicService = MusicService();
  late Library library;
  bool loaded = false;

  @override
  void initState() {
    loadLibrary();
    super.initState();
  }

  loadLibrary() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
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

  addMusicToLibrary() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) => MusicSelectToLibraryPage(libraryId: library.id),
          ),
        )
        .then((_) => loadLibrary());
  }

  bool isSetCurrentPlaylist = false;
  Future<void> setCurrentPlaylist() async {
    if (isSetCurrentPlaylist) return;
    isSetCurrentPlaylist = true;
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    await playerProvider.audioHandler.setPlaylistFromMusics(
      playerProvider.musics,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) return Container();

    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    final musics = playerProvider.musics;

    return Scaffold(
      appBar: AppBar(
        title: Text(library.title),
        actions: [
          LibraryListItemMenuButton(library: library, onRefresh: loadLibrary),
        ],
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        '${musics.length} bài hát ・ ${musicService.calcTotalDuration(musics)}',
                      ),
                    ),
                    IconButton(
                      onPressed: addMusicToLibrary,
                      icon: Icon(Icons.library_add),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    SizedBox(
                      width: 150,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: const Color.fromARGB(
                              255,
                              167,
                              167,
                              167,
                            ).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        onPressed:
                            musics.isNotEmpty
                                ? () async {
                                  await setCurrentPlaylist();
                                  if (musics.first.path !=
                                      audioHandler.currentMediaItem?.id) {
                                    await audioHandler.playMusic(musics.first);
                                  } else {
                                    audioHandler.seek(Duration.zero);
                                  }
                                }
                                : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: [Icon(Icons.play_arrow), Text('Phát nhạc')],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: const Color.fromARGB(
                              255,
                              167,
                              167,
                              167,
                            ).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        onPressed:
                            musics.isNotEmpty
                                ? () async {
                                  //Fix random not same as current
                                  await setCurrentPlaylist();
                                  await audioHandler.setShuffle(true);
                                  await audioHandler.playMediaItem(
                                    audioHandler.playlist[Random().nextInt(
                                      audioHandler.playlist.length - 1,
                                    )],
                                  );
                                }
                                : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: [Icon(Icons.shuffle), Text('Ngẫu nhiên')],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          if (musics.isEmpty)
            Expanded(
              child: Column(
                children: [
                  NoData(title: 'Danh sách trống!'),
                  ElevatedButton(
                    onPressed: addMusicToLibrary,
                    child: Text('Thêm bài hát'),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: MusicList(
                musics: musics,
                onChanged: (value) => loadLibrary(),
              ),
            ),
          SizedBox(height: 90),
        ],
      ),
    );
  }
}
