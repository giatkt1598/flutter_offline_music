import 'package:flutter/material.dart';
import 'package:flutter_offline_music/i18n/i18n.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/services/music_service.dart';

class MusicListSimpleInfo extends StatelessWidget {
  final musicService = MusicService();
  MusicListSimpleInfo({super.key, required this.musics, this.style});
  final List<Music> musics;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return Text(
      '${tr().nSongs(musics.length)} ・ ${musicService.calcTotalDuration(musics)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}
