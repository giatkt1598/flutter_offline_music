import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/menu_popover.dart';
import 'package:flutter_offline_music/components/music_list_controller_group.dart';
import 'package:flutter_offline_music/components/music_list_item.dart';
import 'package:flutter_offline_music/components/music_list_simple_info.dart';
import 'package:flutter_offline_music/components/no_data.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:provider/provider.dart';

class MusicListFavoritePage extends StatefulWidget {
  const MusicListFavoritePage({super.key});

  @override
  State<MusicListFavoritePage> createState() => _MusicListFavoritePageState();
}

class _MusicListFavoritePageState extends State<MusicListFavoritePage> {
  final musicService = MusicService();

  Future<List<Music>> getMusics() async {
    var rs =
        (await musicService.getListMusicAsync())
            .where((x) => x.isFavorite)
            .toList();
    return rs;
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Yêu thích'),
        actions: [
          MenuPopover<String>(
            onPopoverResult: (result) async {
              if (result == 'remove_all') {
                for (var m in playerProvider.musics) {
                  m.isFavorite = false;
                }
                await musicService.unfavoriteAllMusicAsync();
                playerProvider.setMusics(playerProvider.musics);
                if (playerProvider.currentMusic != null) {
                  playerProvider.currentMusic!.isFavorite = false;
                  playerProvider.setCurrentMusic(playerProvider.currentMusic);
                }

                ToastService.showSuccess(
                  'Đã gỡ bỏ tất cả bài hát khỏi mục Yêu thích',
                );
              }
            },
            trigger:
                (showPopover) => IconButton(
                  onPressed: showPopover,
                  icon: Icon(Icons.more_vert),
                ),
            options: [
              PopupMenuItem(
                value: 'remove_all',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Gỡ bỏ tất cả'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: getMusics(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          playerProvider.setMusics(snapshot.data!);
          final musics = playerProvider.musics;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MusicListSimpleInfo(musics: musics),
              ),
              MusicListControllerGroup(musics: musics),
              if (musics.isEmpty)
                Expanded(child: NoData(title: 'Danh sách trống!')),
              Expanded(
                child: ListView.builder(
                  itemCount: musics.length,
                  itemBuilder: (context, index) {
                    final isLast = index + 1 == musics.length;
                    final music = musics[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MusicListItem(
                                music: music,
                                afterHideItem: () => setState(() {}),
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
