import 'package:flutter/material.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class MusicThumbnail extends StatelessWidget {
  const MusicThumbnail({
    super.key,
    required this.musicPath,
    this.size,
    this.boxShape,
    this.borderRadius,
  });

  final String musicPath;
  final double? size;
  final BoxShape? boxShape;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final audioHandler = Provider.of<PlayerProvider>(context).audioHandler;

    getThumbnail() async {
      return await audioHandler.getPictureFile(musicPath);
    }

    var currentBorderRadius =
        borderRadius ?? BorderRadius.all(Radius.circular(8));

    return SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child: FutureBuilder(
        future: getThumbnail(),
        builder: (_, snapshot) {
          if (snapshot.data == null) {
            return Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: boxShape ?? BoxShape.circle,
                borderRadius:
                    boxShape == BoxShape.rectangle ? currentBorderRadius : null,
              ),
              child: Icon(Icons.music_note_rounded),
            );
          }
          return boxShape == BoxShape.rectangle
              ? ClipRRect(
                borderRadius: currentBorderRadius,
                child: Image.file(snapshot.data!),
              )
              : ClipOval(child: Image.file(snapshot.data!));
        },
      ),
    );
  }
}
