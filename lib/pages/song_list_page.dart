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

  @override
  void initState() {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);

    _musicService.getListMusicAsync().then((rs) {
      setState(() {
        _musics = rs;
      });

      playerProvider.setPlaylist(rs);
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
    final playerProvider = Provider.of<PlayerProvider>(context);

    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            SizedBox(height: 12),
            Text('20 bài hát ・ 45 phút'),
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
                              if (_musics.first.id !=
                                  playerProvider.music?.id) {
                                playerProvider.stopAsync().then((_) {
                                  playerProvider.setMusic(_musics.first);
                                  playerProvider.play();
                                });
                              } else {
                                playerProvider.seek(0);
                              }
                            }
                            : null,
                    child: Text('Phát nhạc'),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: OutlinedButton(onPressed: null, child: Text('Trộn')),
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
