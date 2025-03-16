import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:flutter_offline_music/providers/setting_provider.dart';
import 'package:flutter_offline_music/utilities/theme_helper.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class MusicListItemRrect extends StatelessWidget {
  const MusicListItemRrect({super.key, required this.music});

  final Music music;

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final setting = Provider.of<SettingProvider>(context).appSetting;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => playerProvider.openAudioPlayerPage(context, music: music),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Column(
            spacing: 4,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  MusicThumbnail(
                    thumbnailPath: music.thumbnail,
                    boxShape: BoxShape.rectangle,
                    fallbackWidget: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.music_note_rounded, size: 48),
                    ),
                    size: 100,
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).textTheme.bodyMedium!.color!)
                            .withValues(alpha: 0.2),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: (isDarkMode() ? Colors.black : Colors.white)
                            .withValues(alpha: 0.3),
                      ),
                      child: Text(
                        timeago.format(
                          music.creationTime,
                          locale: setting.languageCode,
                        ),
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                music.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
