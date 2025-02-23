import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/song_list_item.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:provider/provider.dart';

class SongListPage extends StatefulWidget {
  const SongListPage({super.key});

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final _scrollController = ScrollController();

  final MusicService _musicService = MusicService();
  List<Music> _musics = [];
  int _totalMinutes = 0;

  @override
  void initState() {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);

    _musicService.getListMusicAsync().then((rs) {
      if (rs.isEmpty) return;
      int totalDurationInSeconds = rs
          .map((m) => m.lengthInSecond)
          .reduce((a, b) => a + b);

      setState(() {
        _musics = rs;
        _totalMinutes = totalDurationInSeconds ~/ 60;
      });

      if (playerProvider.audioHandler.playlist.isEmpty) {
        playerProvider.audioHandler.setPlaylist(
          rs
              .map(
                (e) => MediaItem(id: e.path, title: e.title, artist: e.artist),
              )
              .toList(),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioHandler = Provider.of<PlayerProvider>(context).audioHandler;
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            SizedBox(height: 12),
            Text('${_musics.length} bài hát ・ $_totalMinutes phút'),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    onPressed:
                        _musics.isNotEmpty
                            ? () {
                              if (_musics.first.path !=
                                  audioHandler.currentMediaItem?.id) {
                                audioHandler.stop().then((_) {
                                  audioHandler.playMusic(_musics.first);
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
                  width: 120,
                  child: OutlinedButton(
                    onPressed:
                        _musics.isNotEmpty
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
            for (var item in _musics) SongListItem(music: item),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
