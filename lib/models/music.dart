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
    );
  }
}
