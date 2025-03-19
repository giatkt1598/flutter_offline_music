import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_list_item.dart';
import 'package:flutter_offline_music/components/music_list_simple_info.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/services/music_service.dart';

class MusicListMostListenedPage extends StatefulWidget {
  const MusicListMostListenedPage({super.key});

  @override
  State<MusicListMostListenedPage> createState() =>
      _MusicListMostListenedPageState();
}

class _MusicListMostListenedPageState extends State<MusicListMostListenedPage> {
  final musicService = MusicService();

  Future<List<Music>> getMusics() async {
    return (await musicService.getListMusicAsync())
        .where((x) => x.playedCount > 0)
        .orderByDescending((x) => x.playedCount)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr().dashboard_mostListening)),
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
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final isLast = index + 1 == snapshot.data!.length;
                    final music = snapshot.data![index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MusicListItem(
                                music: music,
                                afterHideItem: () => setState(() {}),
                                leading: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 2,
                                  children: [
                                    Text(
                                      music.playedCount.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Icon(Icons.headphones, size: 16),
                                    MusicThumbnail(
                                      thumbnailPath: music.thumbnail,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isLast) SizedBox(height: 90),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
