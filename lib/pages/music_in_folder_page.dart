import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/song_list_item.dart';
import 'package:flutter_offline_music/models/music_folder.dart';

class MusicInFolderPage extends StatefulWidget {
  const MusicInFolderPage({super.key, required this.musicFolder});

  final MusicFolder musicFolder;

  @override
  State<MusicInFolderPage> createState() => _MusicInFolderPageState();
}

class _MusicInFolderPageState extends State<MusicInFolderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.musicFolder.name),
            Opacity(
              opacity: 0.4,
              child: Text(
                '(${widget.musicFolder.musics.length} bài hát)',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children:
              widget.musicFolder.musics
                  .map((m) => SongListItem(music: m))
                  .toList(),
        ),
      ),
    );
  }
}
