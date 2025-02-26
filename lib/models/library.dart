import 'package:flutter_offline_music/models/music.dart';

class Library {
  final int id;
  final String title;
  final DateTime creationTime;
  DateTime? lastModificationTime;
  List<Music> musics = [];

  Library({
    required this.id,
    required this.title,
    required this.creationTime,
    this.lastModificationTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'creationTime': creationTime.toIso8601String(),
      'lastModificationTime': lastModificationTime?.toIso8601String(),
    };
  }

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'],
      title: json['title'],
      creationTime: DateTime.parse(json['creationTime']),
      lastModificationTime: DateTime.tryParse(
        json['lastModificationTime'] ?? '',
      ),
    );
  }
}
