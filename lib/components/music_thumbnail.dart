import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline_music/services/music_service.dart';

class MusicThumbnail extends StatelessWidget {
  MusicThumbnail({
    super.key,
    required this.musicPath,
    this.size,
    this.boxShape,
    this.borderRadius,
    this.fallbackWidget,
  });

  final String musicPath;
  final double? size;
  final BoxShape? boxShape;
  final BorderRadiusGeometry? borderRadius;
  final Widget? fallbackWidget;
  final _musicService = MusicService();

  Future<File?> getThumbnail() {
    return _musicService.getMusicThumbnailAsync(musicPath);
  }

  @override
  Widget build(BuildContext context) {
    var currentBorderRadius =
        borderRadius ?? BorderRadius.all(Radius.circular(8));

    return SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child: FutureBuilder(
        future: getThumbnail(),
        builder: (_, snapshot) {
          if (snapshot.data == null) {
            return fallbackWidget ??
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: boxShape ?? BoxShape.circle,
                    borderRadius:
                        boxShape == BoxShape.rectangle
                            ? currentBorderRadius
                            : null,
                  ),
                  child: Icon(Icons.music_note_rounded),
                );
          }
          return boxShape == BoxShape.rectangle
              ? ClipRRect(
                borderRadius: currentBorderRadius,
                child: Image.file(snapshot.data!, fit: BoxFit.cover),
              )
              : ClipOval(child: Image.file(snapshot.data!, fit: BoxFit.cover));
        },
      ),
    );
  }
}
