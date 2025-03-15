import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_item_menu.dart';
import 'package:flutter_offline_music/components/music_list_item.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/components/no_data.dart';
import 'package:flutter_offline_music/components/show_confirm_dialog.dart';
import 'package:flutter_offline_music/components/simple_tab.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:provider/provider.dart';

class PlayerPlaylistTabContent extends StatefulWidget {
  const PlayerPlaylistTabContent({super.key});

  @override
  State<PlayerPlaylistTabContent> createState() =>
      _PlayerPlaylistTabContentState();
}

class _PlayerPlaylistTabContentState extends State<PlayerPlaylistTabContent>
    with AutomaticKeepAliveClientMixin {
  final _musicService = MusicService();
  final _scrollController = ScrollController(keepScrollOffset: true);
  List<Music> musics = [];
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

  Future<void> fetchData() async {
    var rs = await _musicService.getListMusicAsync(isHidden: null);
    setState(() {
      musics = rs;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;

    if (audioHandler.playlist.isEmpty || musics.isEmpty) {
      return NoData();
    }

    String totalDuration = _musicService.calcTotalDuration(
      musics
          .where((m) => audioHandler.playlist.any((item) => m.path == item.id))
          .toList(),
    );

    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${audioHandler.currentIndex + 1}/${audioHandler.playlist.length}',
                    ),
                    TextSpan(text: ' ・ '),
                    TextSpan(text: totalDuration),
                  ],
                ),
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () async {
                await audioHandler.setShuffle(true);
                setState(() {});
                ToastService.showSuccess('Đã trộn danh sách');
              },
              icon: Icon(Icons.shuffle),
            ),
            IconButton(
              onPressed: () {
                showConfirmDialog(
                  context: context,
                  message: 'Xóa tất cả bài hát khỏi danh sách phát?',
                ).then((isConfirm) {
                  if (isConfirm == true) {
                    Navigator.of(context).pop(true);
                    audioHandler.stop().then((_) {
                      audioHandler.setPlaylist([]);
                    });
                  }
                });
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        Expanded(
          child: ReorderableListView.builder(
            scrollController: _scrollController,
            onReorder: audioHandler.reorderPlaylist,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  return Material(
                    elevation: 6,
                    color: Colors.white.withValues(alpha: 0.4),
                    child: child,
                  );
                },
                child: child,
              );
            },
            itemCount: audioHandler.playlist.length,
            itemBuilder: (context, index) {
              final music = musics.firstWhere(
                (x) => x.path == audioHandler.playlist[index].id,
              );

              final isCurrent = audioHandler.currentMediaItem?.id == music.path;
              return Container(
                key: ValueKey(music.path),
                color:
                    isCurrent
                        ? Theme.of(
                          context,
                        ).colorScheme.inversePrimary.withValues(alpha: 0.25)
                        : null,
                child: MusicListItem(
                  music: music,
                  onTap: () {
                    if (isCurrent) {
                      var simpleTab =
                          context.findAncestorStateOfType<SimpleTabState>();
                      simpleTab?.activeTab(1);
                    } else {
                      audioHandler.playMusic(music);
                    }
                  },
                  showMiniPlayer: false,
                  musicTitleColor: Colors.white,
                  activeMusicTitleColor:
                      Theme.of(context).colorScheme.inversePrimary,
                  musicArtistColor: Colors.white,
                  menuType: MusicMenuType.inPlaylist,
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: Row(
                      spacing: 4,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sort, color: Colors.white),
                        MusicThumbnail(musicPath: music.path),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
