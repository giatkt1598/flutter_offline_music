import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/app_button.dart';
import 'package:flutter_offline_music/components/duration_picker.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/pages/player_pages/player_page.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:provider/provider.dart';

extension PlayerProviderExtension on BuildContext {
  PlayerProvider getSettingProvider() {
    return Provider.of<PlayerProvider>(this);
  }
}

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

  void notifyChanges() {
    notifyListeners();
  }

  Future openAudioPlayerPage(
    BuildContext context, {
    required Music music,
  }) async {
    Future play() async {
      if (audioHandler.playlist.isEmpty) {
        await audioHandler.setPlaylistFromMusics(musics);
      }

      if (music.path != audioHandler.currentMediaItem?.id) {
        await audioHandler.stop();
        await audioHandler.playMusic(music);
      }
    }

    await play();

    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(),
      builder: (context) {
        return SizedBox(height: SharedData.fullHeight, child: PlayerPage());
      },
    );
  }

  Future<void> setStopTime(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        Duration? newDuration = audioHandler.stopTime?.difference(
          DateTime.now(),
        );

        return SizedBox(
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Hẹn giờ ngủ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16, width: 30, child: Divider()),
              DurationPicker(
                value: newDuration,
                onChanged: (du) {
                  newDuration = du == Duration.zero ? null : du;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 64, left: 64),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  SizedBox(
                    width: 120,
                    child: AppButton(
                      type: AppButtonType.secondary,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: AppButton(
                      type: AppButtonType.primary,
                      onPressed: () {
                        audioHandler.setStopTime(duration: newDuration);
                        String message = '';
                        if (newDuration != null &&
                            newDuration! > Duration.zero) {
                          message =
                              'Tắt nhạc sau ${fDurationLong(newDuration!)}';
                        } else {
                          message = "Đã tắt hẹn giờ";
                        }
                        ToastService.showSuccess(message);
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
