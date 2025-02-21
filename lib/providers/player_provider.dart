import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:just_audio/just_audio.dart';

class PlayerProvider extends ChangeNotifier {
  bool get isPlaying => _player.playing;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  Duration _position = Duration.zero;
  Duration get position => _position;

  var _player = AudioPlayer();
  AudioPlayer get player => _player;

  Music? _music;
  Music? get music => _music;
  void setMusic(Music? music) {
    _music = music;
  }

  List<Music> _playlist = [];
  List<Music> get playlist => _playlist;
  void setPlaylist(List<Music> playlist) {
    _playlist = playlist;
  }

  int get currentIndex => _playlist.indexWhere((x) => x.id == _music?.id);

  void play() async {
    if (music == null) return;

    if (_player.duration == null) {
      if (!File(music!.path).existsSync()) {
        print('Not found path ${music!.path}');
        return;
      }

      await _player.setFilePath(music!.path);
      _player.durationStream.listen((d) {
        _duration = d ?? Duration.zero;
        notifyListeners();
      });

      _player.positionStream.listen((p) {
        _position = p;

        if (_position == _duration) {
          if (canNext) {
            next();
          } else {
            _player.stop();
          }
        }
        notifyListeners();
      });
    } else if (_position == _duration) {
      seek(0);
    }
    _player.play();
    notifyListeners();
  }

  void pause() {
    _player.pause();
    notifyListeners();
  }

  bool get canPrevious => _playlist.isNotEmpty && currentIndex > 0;
  void previous() {
    if (!canPrevious) return;

    stopAsync().then((_) {
      setMusic(playlist[currentIndex - 1]);
      play();
    });
  }

  bool get canNext =>
      _playlist.isNotEmpty && currentIndex + 1 < _playlist.length;
  void next() {
    if (!canNext) return;
    stopAsync().then((_) {
      setMusic(playlist[currentIndex + 1]);
      play();
    });
  }

  Future stopAsync() async {
    await _player.stop();
    await _player.dispose();
    _player = AudioPlayer();
  }

  void seek(double value) {
    _player.seek(Duration(seconds: value.toInt()));
  }
}
