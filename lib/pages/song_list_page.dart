import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/song_list_item.dart';
import 'package:flutter_offline_music/components/song_list_sort_button.dart';
import 'package:flutter_offline_music/constants/constant.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongListPage extends StatefulWidget {
  const SongListPage({super.key});

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final _scrollController = ScrollController();

  final MusicService _musicService = MusicService();
  Duration _totalDuration = Duration.zero;

  String? sortField;
  String? sortDirection;

  fetchData({String? sortField, String? sortDirection}) async {
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

    if (musics.isEmpty) return;
    int totalDurationInSeconds = musics
        .map((m) => m.lengthInSecond)
        .reduce((a, b) => a + b);

    setState(() {
      playerProvider.setMusics(musics);
      _totalDuration = Duration(seconds: totalDurationInSeconds);
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    final musics = playerProvider.musics;
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            SizedBox(height: 12),
            Text('${musics.length} bài hát ・ ${fDuration(_totalDuration)}'),
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
                            ? () {
                              if (musics.first.path !=
                                  audioHandler.currentMediaItem?.id) {
                                audioHandler.stop().then((_) {
                                  audioHandler.playMusic(musics.first);
                                });
                              } else {
                                audioHandler.seek(Duration.zero);
                              }
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
                            ? () {
                              audioHandler.setShuffle(true);
                              audioHandler.stop().then((_) {
                                audioHandler.playMediaItem(
                                  audioHandler.playlist[Random().nextInt(
                                    audioHandler.playlist.length - 1,
                                  )],
                                );
                              });
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
            ListView.builder(
              itemCount: musics.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return SongListItem(music: musics[index]);
              },
            ),
            SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}
