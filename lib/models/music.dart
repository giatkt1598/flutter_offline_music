import 'dart:convert';

import 'package:audio_service/audio_service.dart';

class Music {
  int id;
  int musicFolderId;
  String title;
  String path;
  String? artist;
  int lengthInSecond;
  Duration get duration => Duration(seconds: lengthInSecond);
  String? thumbnail;
  String? genre;
  DateTime? creationTime;
  bool isHidden;
  int? skipSilentStart;
  int? skipSilentEnd;
  Duration? get skipSilentStartDuration =>
      skipSilentStart != null ? Duration(milliseconds: skipSilentStart!) : null;
  Duration? get skipSilentEndDuration =>
      skipSilentEnd != null ? Duration(milliseconds: skipSilentEnd!) : null;

  Music({
    required this.id,
    required this.musicFolderId,
    required this.title,
    required this.path,
    this.artist,
    this.lengthInSecond = 0,
    this.thumbnail,
    this.genre,
    this.creationTime,
    this.isHidden = false,
    this.skipSilentStart,
    this.skipSilentEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'musicFolderId': musicFolderId,
      'title': title,
      'path': path,
      'artist': artist,
      'lengthInSecond': lengthInSecond,
      'thumbnail': thumbnail,
      'genre': genre,
      'creationTime': creationTime?.toIso8601String(),
      'isHidden': isHidden ? 1 : 0,
      'skipSilentStart': skipSilentStart,
      'skipSilentEnd': skipSilentEnd,
    };
  }

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'],
      musicFolderId: json['musicFolderId'],
      title: json['title'],
      path: json['path'],
      genre: json['genre'],
      thumbnail: json['thumbnail'],
      artist: json['artist'],
      lengthInSecond: json['lengthInSecond'],
      creationTime: DateTime.tryParse(json['creationTime'] ?? ''),
      isHidden: json['isHidden'] == 1,
      skipSilentStart: json['skipSilentStart'],
      skipSilentEnd: json['skipSilentEnd'],
    );
  }

  MediaItem toMediaItem() {
    return MediaItem(
      id: path,
      title: title,
      artist: artist ?? '<Không rõ tác giả>',
      album: 'Tất cả',
      duration: duration,
      extras: {'music': this},
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
