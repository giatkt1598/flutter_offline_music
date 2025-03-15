import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_list.dart';
import 'package:flutter_offline_music/components/music_list_simple_info.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/services/music_service.dart';

class MusicListRecentPlayingPage extends StatefulWidget {
  const MusicListRecentPlayingPage({super.key});

  @override
  State<MusicListRecentPlayingPage> createState() =>
      _MusicListRecentPlayingPageState();
}

class _MusicListRecentPlayingPageState
    extends State<MusicListRecentPlayingPage> {
  final musicService = MusicService();

  Future<List<Music>> getMusics() async {
    return (await musicService.getListMusicAsync())
        .where((x) => x.playedLastTime != null)
        .orderByDescending((x) => x.playedLastTime!)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đã phát gần đây')),
      body: FutureBuilder(
        future: getMusics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MusicListSimpleInfo(musics: snapshot.data!),
              ),
              Expanded(
                child: MusicList(
                  musics: snapshot.data!,
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
