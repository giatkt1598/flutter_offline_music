import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';

class PlayerProvider extends ChangeNotifier {
  bool isShowMiniPlayer = true;
  AppAudioHandler get audioHandler => AppAudioHandler.instance;
  List<Music> musics = [];

  void hideMiniPlayer() {
    isShowMiniPlayer = false;
    notifyListeners();
  }

  void showMiniPlayer() {
    isShowMiniPlayer = true;
    notifyListeners();
  }

  setMusics(List<Music> musics) {
    this.musics = musics;
    audioHandler.setPlaylist(
      this.musics
          .map(
            (e) => MediaItem(
              id: e.path,
              title: e.title,
              artist: e.artist ?? '<Không rõ tác giả>',
              album: 'Tất cả',
            ),
          )
          .toList(),
    );

    notifyListeners();
  }

  PlayerProvider() {
    audioHandler.addListener(notifyListeners);
  }
}
