import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_offline_music/components/music_list.dart';
import 'package:flutter_offline_music/components/music_list_controller_group.dart';
import 'package:flutter_offline_music/components/music_list_simple_info.dart';
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
  List<Music>? musics;

  @override
  void initState() {
    super.initState();
    EasyLoading.show(status: 'Đang tải...');
    fetchData();
  }

  Future<void> fetchData({String? sortField, String? sortDirection}) async {
    await Future.delayed(Duration(milliseconds: 500));
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
    EasyLoading.dismiss();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (musics == null) {
      return Container();
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: MusicList(
              musics: musics!,
              onChanged: (value) => setState(() {}),
              leadingItem: Column(
                children: [
                  SizedBox(height: 12),
                  MusicListSimpleInfo(musics: musics!),
                  SizedBox(height: 12),
                  MusicListControllerGroup(),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      if (musics!.isNotEmpty &&
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
