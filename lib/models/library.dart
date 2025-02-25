import 'package:flutter_offline_music/models/music.dart';

class Library {
  final int id;
  final String title;
  final DateTime creationTime;
  List<Music> musics = [];

  Library({required this.id, required this.title, required this.creationTime});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'creationTime': creationTime.toIso8601String(),
    };
  }

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      id: json['id'],
      title: json['title'],
      creationTime: DateTime.parse(json['creationTime']),
    );
  }
}
