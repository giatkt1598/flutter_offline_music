import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_offline_music/components/app_button.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/services/music_service.dart';
import 'package:flutter_offline_music/services/toast_service.dart';
import 'package:flutter_offline_music/services/youtube_service.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:provider/provider.dart';

class DownloadAllMusicThumbnailFromYoutube extends StatefulWidget {
  const DownloadAllMusicThumbnailFromYoutube({super.key, required this.musics});
  final List<Music> musics;
  @override
  State<DownloadAllMusicThumbnailFromYoutube> createState() =>
      _DownloadAllMusicThumbnailFromYoutubeState();
}

class _DownloadAllMusicThumbnailFromYoutubeState
    extends State<DownloadAllMusicThumbnailFromYoutube> {
  final musicService = MusicService();
  final youtubeService = YoutubeService();
  double progress = 0;
  int numHasThumbnail = 0;
  Music? currentMusic;
  int numSuccess = 0;
  int numFailed = 0;
  final List<Music> musics = [];

  @override
  void initState() {
    super.initState();
    downloadThumbnails();
  }

  Future downloadThumbnails() async {
    musics.clear();
    final allMusics = await musicService.getListMusicAsync();
    for (var m in widget.musics) {
      musics.add(allMusics.firstWhere((x) => x.id == m.id));
    }
    numHasThumbnail = musics.where((x) => x.thumbnail != null).length;

    if (musics.isEmpty) return;
    for (var i = 0; i < musics.length; i++) {
      if (!mounted) return;
      setState(() {
        progress = i / musics.length;
      });
      if (musics[i].thumbnail != null) continue;

      setState(() {
        currentMusic = musics[i];
      });

      try {
        String? thumbFilePath = await youtubeService.getVideoThumbnailAsync(
          currentMusic!.title,
        );
        if (thumbFilePath != null) {
          currentMusic!.thumbnail = thumbFilePath;
          numSuccess++;
        } else {
          numFailed++;
        }
      } catch (_) {
        numFailed++;
      }
    }

    setState(() {
      currentMusic = null;
      progress = 1;
    });
  }

  Future<void> handleSave() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    EasyLoading.show(status: 'Đang lưu...', dismissOnTap: false);
    for (var m in musics) {
      await musicService.updateMusicAsync(m);

      var musicInList =
          playerProvider.musics.where((x) => x.id == m.id).firstOrNull;
      if (musicInList != null) {
        musicInList.thumbnail = m.thumbnail;
      }
    }

    await playerProvider.audioHandler.updateThumbnailToPlaylistItems();
    playerProvider.notifyChanges();

    EasyLoading.dismiss();
    ToastService.showSuccess('Hoàn thành!');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Tải ảnh bìa từ Youtube',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: SizedBox(
        width: SharedData.fullWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text('Tiến độ: ${(progress * 100).round()}%'),
            LinearProgressIndicator(value: progress),
            if (currentMusic != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      currentMusic!.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (progress == 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        Text(
                          'Hoàn thành!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(child: SizedBox(width: 30, child: Divider())),
                  Opacity(
                    opacity: 0.4,
                    child: DefaultTextStyle(
                      style:
                          Theme.of(context).textTheme.bodySmall ?? TextStyle(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tổng: ${musics.length}'),
                          Text('Đã có (không tải nữa): $numHasThumbnail'),
                          Text('Tải thành công: $numSuccess'),
                          Text('Tải thất bại: $numFailed'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        AppButton(
          child: Text('Hủy bỏ'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          type: AppButtonType.primary,
          onPressed: progress < 1 || numSuccess == 0 ? null : handleSave,
          child: Text('Lưu'),
        ),
      ],
    );
  }
}
