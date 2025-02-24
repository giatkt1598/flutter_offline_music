import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:flutter_offline_music/services/database_helper.dart';
import 'package:sqflite/sqlite_api.dart';

class MusicService {
  static const String tableMusicFolder = 'MusicFolder';
  static const String tableMusic = 'Music';

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<int> insertMusicFolderAsync(MusicFolder model) async {
    var values = model.toJson();
    values['id'] = null;
    return await (await _db).insert(tableMusicFolder, values);
  }

  Future deleteMusicFolderAsync(int id) async {
    await (await _db).delete(
      tableMusicFolder,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future deleteAllMusicFolderAsync() async {
    await (await _db).delete(tableMusicFolder);
  }

  Future<List<MusicFolder>> getMusicFolderListAsync() async {
    var queryRs = await (await _db).query(tableMusicFolder);
    var list = queryRs.map((e) => MusicFolder.fromJson(e)).toList();

    var musics = await getListMusicAsync();

    for (var folder in list) {
      folder.musics =
          musics.where((x) => x.musicFolderId == folder.id).toList();
    }

    return list;
  }

  Future deleteAllMusicAsync() async {
    await (await _db).delete(tableMusic);
  }

  Future insertMusicAsync(Music model) async {
    var values = model.toJson();
    values['id'] = null;
    await (await _db).insert(tableMusic, values);
  }

  Future<List<Music>> getListMusicAsync({
    int? musicFolderId,
    String? orderBy,
  }) async {
    final db = await _db;
    var queryRs =
        musicFolderId != null
            ? await db.query(
              tableMusic,
              where: 'musicFolderId = ?',
              orderBy: orderBy,
              whereArgs: [musicFolderId],
            )
            : await db.query(tableMusic, orderBy: orderBy);
    var list = queryRs.map((e) => Music.fromJson(e)).toList();
    return list;
  }
}
