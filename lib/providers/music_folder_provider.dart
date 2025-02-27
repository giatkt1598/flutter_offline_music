import 'package:flutter/material.dart';

class MusicFolderProvider extends ChangeNotifier {
  bool isShowAllMusicFolder = false;
  void setShowAllMusicFolder(bool isShowAllMusicFolder) {
    this.isShowAllMusicFolder = isShowAllMusicFolder;
    notifyListeners();
  }
}
