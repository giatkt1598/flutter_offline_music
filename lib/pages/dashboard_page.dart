import 'dart:math';

import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/button_card.dart';
import 'package:flutter_offline_music/components/music_list_empty.dart';
import 'package:flutter_offline_music/components/music_list_item.dart';
import 'package:flutter_offline_music/components/music_list_item_card.dart';
import 'package:flutter_offline_music/components/music_list_item_rrect.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/tab_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TabProviderListenerMixin, AutomaticKeepAliveClientMixin {
  List<Music> _recentMusics = [];
  List<Music> _newestMusics = [];
  List<Music> _topPlayedCountMusics = [];
  final _musicService = MusicService();
  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    var allMusics = await _musicService.getListMusicAsync();
    setState(() {
      _recentMusics =
          allMusics
              .where((x) => x.playedLastTime != null)
              .orderByDescending((x) => x.playedLastTime!)
              .take(3)
              .toList();

      _newestMusics =
          allMusics
              .where(
                (x) =>
                    DateTime.now().difference(x.creationTime) <
                    Duration(days: 90),
              )
              .orderByDescending((x) => x.creationTime)
              .take(10)
              .toList();

      _topPlayedCountMusics =
          allMusics
              .where((x) => x.playedCount > 0)
              .orderByDescending((x) => x.playedCount)
              .take(10)
              .toList();
    });

    playerProvider.setMusics(allMusics); //TODO: workaround
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    playNow() async {
      if (playerProvider.musics.isEmpty) {
        ToastService.showError('Không có bài hát nào để phát');
        return;
      }
      await playerProvider.audioHandler.setPlaylistFromMusics(
        playerProvider.musics,
      );
      await playerProvider.audioHandler.playMusic(
        playerProvider.musics[Random().nextInt(
          playerProvider.musics.length - 1,
        )],
      );
      playerProvider.showMiniPlayer();
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Row(
              spacing: 8,
              children: [
                Flexible(
                  flex: 1,
                  child: ButtonCard(
                    icon: Icon(Icons.favorite),
                    backgroundImage: AssetImage("assets/bg_music_pink.png"),
                    onPressed: () {
                      ToastService.show(
                        message: 'Lười làm tính năng này quá :D',
                      );
                    },
                    child: Text(
                      'Yêu thích',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: ButtonCard(
                    icon: Icon(Icons.play_arrow_rounded, size: 32),
                    backgroundImage: AssetImage("assets/bg_music_blue.png"),
                    onPressed: playNow,
                    child: Text(
                      'Phát nhạc',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GroupTitle(title: 'Đã phát gần đây'),
                for (var music in _recentMusics)
                  MusicListItem(music: music, afterHideItem: () => fetchData()),
                if (_recentMusics.isEmpty) MusicListEmpty(),
              ],
            ),
            _GroupTitle(title: 'Đã thêm gần đây'),
            SizedBox(
              height: 160,
              width: SharedData.fullWidth,
              child:
                  _newestMusics.isEmpty
                      ? MusicListEmpty()
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _newestMusics.length,
                        itemBuilder:
                            (context, idx) =>
                                MusicListItemRrect(music: _newestMusics[idx]),
                      ),
            ),
            _GroupTitle(title: 'Lượt nghe nhiều nhất'),
            SizedBox(
              height: 200,
              child:
                  _topPlayedCountMusics.isEmpty
                      ? MusicListEmpty()
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _topPlayedCountMusics.length,
                        itemBuilder:
                            (context, idx) => MusicListItemCard(
                              music: _topPlayedCountMusics[idx],
                            ),
                      ),
            ),
            SizedBox(height: 90),
          ],
        ),
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

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        TextButton(onPressed: () {}, child: Text('Xem thêm >')),
      ],
    );
  }
}
