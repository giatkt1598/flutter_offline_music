import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_item_menu.dart';
import 'package:flutter_offline_music/components/music_list_item.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/components/no_data.dart';
import 'package:flutter_offline_music/components/show_confirm_dialog.dart';
import 'package:flutter_offline_music/components/simple_tab.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:flutter_offline_music/utilities/string_extensions.dart';
import 'package:flutter_offline_music/utilities/theme_helper.dart';
import 'package:provider/provider.dart';

class MusicPlaylist extends StatefulWidget {
  const MusicPlaylist({super.key, this.onCurrentItemPressed});

  final Function? onCurrentItemPressed;
  @override
  State<MusicPlaylist> createState() => _MusicPlaylistState();
}

class _MusicPlaylistState extends State<MusicPlaylist>
    with AutomaticKeepAliveClientMixin {
  final _musicService = MusicService();
  final _scrollController = ScrollController();
  List<Music> musics = [];
  final _firstItemKey = GlobalKey(); // use for finding height of item to scroll
  @override
  void initState() {
    fetchData().then((_) {
      final currentIndex =
          Provider.of<PlayerProvider>(
            context,
            listen: false,
          ).audioHandler.currentIndex;
      if (currentIndex > -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          jumpToIndex(currentIndex);
        });
      }
    });
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

  void jumpToIndex(int index) {
    double itemHeight = _firstItemKey.currentContext?.size?.height ?? 60;
    double offset = max(
      index * itemHeight - itemHeight * 2 + itemHeight / 2,
      0,
    );
    offset = min(offset, _scrollController.position.maxScrollExtent);
    _scrollController.jumpTo(offset);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    final settingProvider = context.getSettingProvider();

    if (audioHandler.playlist.isEmpty || musics.isEmpty) {
      return NoData();
    }

    String totalDuration = _musicService.calcTotalDuration(
      musics
          .where((m) => audioHandler.playlist.any((item) => m.path == item.id))
          .toList(),
    );

    String? bgImage =
        audioHandler.currentMusic?.thumbnail ??
        settingProvider.appSetting.playerBackgroundImage.toNullIfEmpty();

    return Column(
      children: [
        Container(
          color:
              bgImage != null
                  ? Colors.transparent
                  : Theme.of(context).scaffoldBackgroundColor,
          child: Row(
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
                  ToastService.showSuccess(tr().playlist_shuffleSuccess);
                },
                icon: Icon(Icons.shuffle),
              ),
              IconButton(
                onPressed: () {
                  showConfirmDialog(
                    context: context,
                    message: tr().playlist_removeAllItemsConfirmMessage,
                  ).then((isConfirm) {
                    if (isConfirm == true) {
                      Navigator.of(context).pop(true);
                      audioHandler.stop().then((_) {
                        audioHandler.setPlaylistFromMusics([]);
                      });
                    }
                  });
                },
                icon: Icon(Icons.delete),
              ),
            ],
          ),
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
                key: index == 0 ? _firstItemKey : ValueKey(music.path),
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
                      if (widget.onCurrentItemPressed != null) {
                        widget.onCurrentItemPressed!();
                      } else {
                        var simpleTab =
                            context.findAncestorStateOfType<SimpleTabState>();
                        simpleTab?.activeTab(1);
                      }
                    } else {
                      audioHandler.playMusic(music);
                    }
                  },
                  showMiniPlayer: false,
                  musicTitleColor: Colors.white,
                  activeMusicTitleColor:
                      isDarkMode()
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.inversePrimary,
                  musicArtistColor: Colors.white,
                  menuType: MusicMenuType.inPlaylist,
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: Row(
                      spacing: 4,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.drag_handle_rounded, color: Colors.white),
                        MusicThumbnail(thumbnailPath: music.thumbnail),
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
