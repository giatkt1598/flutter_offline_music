import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_page.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';

class PlayerProvider extends ChangeNotifier {
  bool isShowMiniPlayer = true;
  AppAudioHandler get audioHandler => AppAudioHandler.instance;
  List<Music> musics = [];
  int? currentLibraryId;

  void hideMiniPlayer() {
    isShowMiniPlayer = false;
    notifyListeners();
  }

  void showMiniPlayer() {
    isShowMiniPlayer = true;
    notifyListeners();
  }

  Future<void> setMusics(List<Music> musics) async {
    this.musics = musics;
    notifyListeners();
  }

  Future openAudioPlayerPage(BuildContext context, {required Music music}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(),
      builder: (context) {
        return SizedBox(
          height: SharedData.fullHeight,
          child: PlayerPage(music: music),
        );
      },
    );
  }

  PlayerProvider() {
    audioHandler.addListener(notifyListeners);

    _init();
  }

  Future<void> _init() async {
    final musicService = MusicService();
    final bool isExecSyncData = SettingProvider.staticAppSetting.autoScanFiles;
    if (isExecSyncData) {
      await musicService.scanMusicAsync(
        onCompleted: (totalNewFile, totalDeletedFile) {
          if (totalNewFile > 0) {
            ToastService.showSuccess('Đã thêm $totalNewFile bài hát từ bộ nhớ');
          }

          if (totalDeletedFile > 0) {
            ToastService.showSuccess(
              'Đã xóa $totalDeletedFile bài hát vì không tìm thấy tệp trong bộ nhớ',
            );
          }
        },
      );
    }

    // final bool isSkipSilent = SettingProvider.staticAppSetting.skipSilent;
    // if (isSkipSilent) {
    //   await musicService.fetchSkipSilentDurations();
    // }
  }
}
