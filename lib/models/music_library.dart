import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/models/music.dart';

class MusicLibrary {
  final int musicId;
  final int libraryId;

  Music? music;
  Library? library;

  MusicLibrary({required this.musicId, required this.libraryId});

  Map<String, dynamic> toJson() {
    return {'musicId': musicId, 'libraryId': libraryId};
  }

  factory MusicLibrary.fromJson(Map<String, dynamic> json) {
    var result = MusicLibrary(
      musicId: json['musicId'],
      libraryId: json['libraryId'],
    );

    result.music = Music.fromJson(json);
    return result;
  }
}
