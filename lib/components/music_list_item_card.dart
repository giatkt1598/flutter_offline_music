import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/music_thumbnail.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/utilities/theme_helper.dart';

class MusicListItemCard extends StatelessWidget {
  const MusicListItemCard({super.key, required this.music});

  final Music music;
  @override
  Widget build(BuildContext context) {
    bool isDark = isDarkMode();
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
      child: Container(
        width: 160,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
          border:
              !isDark
                  ? Border.all(
                    color: Colors.black.withValues(alpha: 0.1),
                    width: 1,
                  )
                  : null,
          boxShadow:
              !isDark
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: -5,
                      offset: Offset(0, 10),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MusicThumbnail(
              musicPath: music.path,
              boxShape: BoxShape.circle,
              size: 90,
              fallbackWidget: CircleAvatar(
                child: Image.asset('assets/music_note_2.png'),
              ),
            ),
            Text(
              music.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                Text('12', style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(Icons.headphones, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
