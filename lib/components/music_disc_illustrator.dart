import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/rotating_disc.dart';
import 'package:flutter_offline_music/components/rotating_image_disc.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:provider/provider.dart';

class MusicDiscIllustrator extends StatefulWidget {
  const MusicDiscIllustrator({super.key});

  @override
  State<MusicDiscIllustrator> createState() => _MusicDiscIllustratorState();
}

class _MusicDiscIllustratorState extends State<MusicDiscIllustrator> {
  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    final settingProvider = Provider.of<SettingProvider>(context);
    final backgroundImage = settingProvider.appSetting.playerBackgroundImage;
    String? thumbnail = audioHandler.currentMediaItem?.artUri?.toFilePath();
    if (thumbnail == null && backgroundImage != '') {
      thumbnail = backgroundImage;
    }
    return thumbnail != null
        ? RotatingImageDisc(backgroundImageUrl: thumbnail)
        : RotatingDisc();
  }
}
