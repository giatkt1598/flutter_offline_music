import 'package:flutter/material.dart';
import 'package:flutter_offline_music/services/audio_handler.dart';

class PlayerProvider extends ChangeNotifier {
  AppAudioHandler get audioHandler => AppAudioHandler.instance;

  PlayerProvider() {
    audioHandler.addListener(notifyListeners);
  }
}
