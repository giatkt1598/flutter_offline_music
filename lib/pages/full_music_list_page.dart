import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_list.dart';
import 'package:flutter_offline_music/components/song_list_sort_button.dart';
import 'package:flutter_offline_music/constants/constant.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/tab_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FullMusicListPage extends StatefulWidget {
  const FullMusicListPage({super.key});

  @override
  State<FullMusicListPage> createState() => _FullMusicListPageState();
}

class _FullMusicListPageState extends State<FullMusicListPage>
    with TabProviderListenerMixin, AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final MusicService _musicService = MusicService();

  String? sortField;
  String? sortDirection;
  List<Music> musics = [];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData({String? sortField, String? sortDirection}) async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final pref = await SharedPreferences.getInstance();
    setState(() {
      this.sortField =
          sortField ??
          pref.getString(Constants.prefKeyAllSongSortField) ??
          'creationTime';
      this.sortDirection =
          sortDirection ??
          pref.getString(Constants.prefKeyAllSongSortDirection) ??
          'desc';
    });
    if (sortField != null) {
      pref.setString(Constants.prefKeyAllSongSortField, sortField);
    }
    if (sortDirection != null) {
      pref.setString(Constants.prefKeyAllSongSortDirection, sortDirection);
    }
    final musics = await _musicService.getListMusicAsync(
      orderBy: '${this.sortField} ${this.sortDirection}',
    );

    playerProvider.setMusics(musics);
    setState(() {
      this.musics = musics;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: MusicList(
              musics: musics,
              onChanged: (value) => setState(() {}),
              leadingItem: Column(
                children: [
                  SizedBox(height: 12),
                  Text(
                    '${musics.length} bài hát ・ ${_musicService.calcTotalDuration(musics)}',
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      SizedBox(
                        width: 140,
                        child: OutlinedButton(
                          onPressed:
                              musics.isNotEmpty
                                  ? () async {
                                    if (musics.first.path !=
                                        audioHandler.currentMediaItem?.id) {
                                      await audioHandler.stop();
                                      await audioHandler.playMusic(
                                        musics.first,
                                      );
                                    } else {
                                      await audioHandler.seek(Duration.zero);
                                    }
                                    setState(() {});
                                  }
                                  : null,
                          child: Text('Phát nhạc'),
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: OutlinedButton(
                          onPressed:
                              musics.isNotEmpty
                                  ? () async {
                                    await audioHandler.setShuffle(true);
                                    await audioHandler.stop();
                                    await audioHandler.playMediaItem(
                                      audioHandler.playlist[Random().nextInt(
                                        audioHandler.playlist.length - 1,
                                      )],
                                    );
                                    setState(() {});
                                  }
                                  : null,
                          child: Text('Ngẫu nhiên'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      if (musics.isNotEmpty &&
                          sortField != null &&
                          sortDirection != null)
                        SongListSortButton(
                          initialSortDirection: sortDirection!,
                          initialSortField: sortField!,
                          onChanged:
                              (sortField, sortDirection) => fetchData(
                                sortDirection: sortDirection,
                                sortField: sortField,
                              ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onTabActive() {
    fetchData();
  }

  @override
  bool get wantKeepAlive => true;
}
