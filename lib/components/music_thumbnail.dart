import 'package:flutter/material.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/providers/player_provider.dart';
import 'package:provider/provider.dart';

class MusicThumbnail extends StatelessWidget {
  const MusicThumbnail({super.key, required this.music});

  final Music music;
  @override
  Widget build(BuildContext context) {
    final audioHandler = Provider.of<PlayerProvider>(context).audioHandler;

    getThumbnail() async {
      return await audioHandler.getPictureFile(music.path);
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: FutureBuilder(
        future: getThumbnail(),
        builder: (_, snapshot) {
          if (snapshot.data == null) {
            return Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.music_note_rounded),
            );
          }
          return ClipOval(child: Image.file(snapshot.data!));
        },
      ),
    );
  }
}
