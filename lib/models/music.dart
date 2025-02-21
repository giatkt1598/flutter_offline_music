class Music {
  int id;
  int musicFolderId;
  String name;
  String path;
  String? author;
  int lengthInSecond = 0;

  Music({
    required this.id,
    required this.musicFolderId,
    required this.name,
    required this.path,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'musicFolderId': musicFolderId,
      'name': name,
      'path': path,
      'author': author,
      'lengthInSecond': lengthInSecond,
    };
  }

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'],
      musicFolderId: json['musicFolderId'],
      name: json['name'],
      path: json['path'],
    );
  }
}
