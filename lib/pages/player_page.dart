import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/blur_image.dart';
import 'package:flutter_offline_music/components/player_audio_tab_content.dart';
import 'package:flutter_offline_music/components/player_header.dart';
import 'package:flutter_offline_music/components/player_playlist_tab_content.dart';
import 'package:flutter_offline_music/components/simple_tab.dart';
import 'package:flutter_offline_music/constants/constant.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.music});

  final Music music;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  int tabIndex = 1;

  @override
  void initState() {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.isShowMiniPlayer = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final audioHandler = playerProvider.audioHandler;
    final settingProvider = Provider.of<SettingProvider>(context);
    final thumbnail = audioHandler.currentMediaItem?.artUri?.toFilePath();
    final backgroundImage =
        thumbnail ?? settingProvider.appSetting.playerBackgroundImage;
    bool isDarkBottom =
        backgroundImage.isNotEmpty ||
        Theme.of(context).brightness == Brightness.light;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        playerProvider.isShowMiniPlayer = true;
      },
      child: Stack(
        children: [
          if (backgroundImage.isNotEmpty)
            BlurImageWidget(
              imagePath: backgroundImage,
              size: Size(SharedData.fullWidth, SharedData.fullHeight),
              sigmaX:
                  settingProvider.appSetting.backgroundBlurValue *
                  Constants.backgroundBlurSigmaMaxValue,
              sigmaY:
                  settingProvider.appSetting.backgroundBlurValue *
                  Constants.backgroundBlurSigmaMaxValue,
            ),
          if (isDarkBottom)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(
                      alpha: 0.7,
                    ), // ✅ Bóng mờ màu đen ở dưới
                  ],
                ),
              ),
            ),
          Column(
            children: [
              SizedBox(height: SharedData.statusBarHeight),
              PlayerHeader(
                music: widget.music,
                playerTab: tabIndex == 0 ? PlayerTab.playlist : PlayerTab.audio,
              ),
              Expanded(
                child: SimpleTab(
                  initialIndex: tabIndex,
                  tabViews: [
                    PlayerPlaylistTabContent(),
                    PlayerAudioTabContent(music: widget.music),
                  ],
                  onTabChanged: (value) {
                    setState(() {
                      tabIndex = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
