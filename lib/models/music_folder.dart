import 'package:flutter_offline_music/models/music.dart';

class MusicFolder {
  int id;
  String path;
  String name;
  bool isHidden;

  List<Music> musics = [];

  MusicFolder({
    required this.id,
    required this.path,
    required this.name,
    this.isHidden = false,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'path': path, 'isHidden': isHidden};
  }

  factory MusicFolder.fromJson(Map<String, dynamic> json) {
    return MusicFolder(
      id: json['id'],
      path: json['path'],
      name: json['name'],
      isHidden: json['isHidden'] == 1,
    );
  }
}
