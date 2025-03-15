import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/rotating_disc.dart';
import 'package:flutter_offline_music/components/rotating_image_disc.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:provider/provider.dart';

class MusicDiscIllustrator extends StatefulWidget {
  const MusicDiscIllustrator({super.key, required this.music});

  final Music music;

  @override
  State<MusicDiscIllustrator> createState() => _MusicDiscIllustratorState();
}

class _MusicDiscIllustratorState extends State<MusicDiscIllustrator> {
  @override
  Widget build(BuildContext context) {
    final settingProvider = Provider.of<SettingProvider>(context);
    final backgroundImage = settingProvider.appSetting.playerBackgroundImage;
    String? thumbnail = widget.music.thumbnail;
    if (thumbnail == null && backgroundImage != '') {
      thumbnail = backgroundImage;
    }
    return thumbnail != null
        ? RotatingImageDisc(backgroundImageUrl: thumbnail)
        : RotatingDisc();
  }
}
