import 'dart:convert';
import 'dart:io';

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
  bool isOriginThumbnail; //Thumbnail image read from metadata of file
  String? genre;
  final DateTime creationTime;
  bool isHidden;
  int? skipSilentStart;
  int? skipSilentEnd;
  DateTime? playedLastTime;
  int playedCount;
  bool isFavorite;
  Duration? get skipSilentStartDuration =>
      skipSilentStart != null ? Duration(milliseconds: skipSilentStart!) : null;
  Duration? get skipSilentEndDuration =>
      skipSilentEnd != null ? Duration(milliseconds: skipSilentEnd!) : null;

  Music({
    required this.id,
    required this.musicFolderId,
    required this.title,
    required this.path,
    required this.creationTime,
    this.artist,
    this.lengthInSecond = 0,
    this.thumbnail,
    this.genre,
    this.isHidden = false,
    this.skipSilentStart,
    this.skipSilentEnd,
    this.playedLastTime,
    this.playedCount = 0,
    this.isFavorite = false,
    this.isOriginThumbnail = false,
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
      'creationTime': creationTime.toIso8601String(),
      'isHidden': isHidden ? 1 : 0,
      'skipSilentStart': skipSilentStart,
      'skipSilentEnd': skipSilentEnd,
      'playedLastTime': playedLastTime?.toIso8601String(),
      'playedCount': playedCount,
      'isFavorite': isFavorite ? 1 : 0,
      'isOriginThumbnail': isOriginThumbnail ? 1 : 0,
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
      creationTime: DateTime.parse(json['creationTime']),
      isHidden: json['isHidden'] == 1,
      skipSilentStart: json['skipSilentStart'],
      skipSilentEnd: json['skipSilentEnd'],
      playedLastTime: DateTime.tryParse(json['playedLastTime'] ?? ''),
      playedCount: json['playedCount'],
      isFavorite: json['isFavorite'] == 1,
      isOriginThumbnail: json['isOriginThumbnail'] == 1,
    );
  }

  MediaItem toMediaItem() {
    return MediaItem(
      id: path,
      title: title,
      artist: artist ?? '<Không rõ tác giả>',
      album: 'Tất cả',
      duration: duration,
      genre: genre,
      artUri: thumbnail != null ? File(thumbnail!).uri : null,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
