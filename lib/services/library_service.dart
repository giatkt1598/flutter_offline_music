import 'package:flutter_offline_music/models/library.dart';
import 'package:flutter_offline_music/models/music_library.dart';
import 'package:flutter_offline_music/services/database_helper.dart';
import 'package:flutter_offline_music/services/db_table.dart';
import 'package:flutter_offline_music/utilities/debug_helper.dart';
import 'package:remove_diacritic/remove_diacritic.dart';
import 'package:sqflite/sqflite.dart';

class LibraryService {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<int> insertAsync(Library model) async {
    var values = model.toJson();
    values['id'] = null;
    return await (await _db).insert(DbTable.library, values);
  }

  Future<int> updateAsync(Library model) async {
    var values = model.toJson();
    return await (await _db).update(
      DbTable.library,
      values,
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future addMusicToLibraryAsync({
    required int musicId,
    required int libraryId,
  }) async {
    var model = MusicLibrary(musicId: musicId, libraryId: libraryId);
    var values = model.toJson();
    try {
      return await (await _db).insert(
        DbTable.musicLibrary,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      logDebug('[addMusicToLibraryAsync] $e');
      rethrow;
    }
  }

  Future<int> removeMusicInLibraryAsync({int? musicId, int? libraryId}) async {
    try {
      String whereClause = "";
      List<dynamic> whereArgs = [];

      if (musicId != null) {
        whereClause += "musicId = ?";
        whereArgs.add(musicId);
      }
      if (libraryId != null) {
        if (whereClause.isNotEmpty) whereClause += " AND ";
        whereClause += "libraryId = ?";
        whereArgs.add(libraryId);
      }
      return await (await _db).delete(
        DbTable.musicLibrary,
        where:
            whereClause.isNotEmpty
                ? whereClause
                : null, // If empty, delete all rows
        whereArgs:
            whereArgs.isNotEmpty ? whereArgs : null, // Prevent SQL errors
      );
    } catch (e) {
      logDebug('[removeMusicInLibraryAsync] $e');
      rethrow;
    }
  }

  Future deleteAsync(int id) async {
    await (await _db).delete(DbTable.library, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Library>> getListAsync({int? id, String? orderBy}) async {
    final db = await _db;
    var queryLibraries = await db.query(
      DbTable.library,
      where: id != null ? 'id = ?' : null,
      orderBy: orderBy,
      whereArgs: id != null ? [id] : null,
    );
    var libraries = queryLibraries.map((e) => Library.fromJson(e)).toList();

    var queryMusicLibraries = await db.rawQuery('''
  SELECT ${DbTable.music}.*, ${DbTable.musicLibrary}.*
  FROM ${DbTable.music}
  JOIN ${DbTable.musicLibrary} ON ${DbTable.music}.id = ${DbTable.musicLibrary}.musicId
  JOIN ${DbTable.musicFolder} ON ${DbTable.music}.musicFolderId = ${DbTable.musicFolder}.id
  WHERE ${DbTable.music}.isHidden = 0 AND ${DbTable.musicFolder}.isHidden = 0 ${id != null ? 'AND ${DbTable.musicLibrary}.libraryId = ? ' : ''}
''', id != null ? [id] : null);

    var musicLibraries =
        queryMusicLibraries.map((e) => MusicLibrary.fromJson(e)).toList();

    for (var lib in libraries) {
      lib.musics =
          musicLibraries
              .where((x) => x.libraryId == lib.id && x.music != null)
              .map((x) => x.music!)
              .toList();
    }
    return libraries;
  }

  Future<List<Library>> searchLibraries(String keyword) async {
    if (keyword.isEmpty) return [];

    keyword = keyword.toLowerCase();
    var allLibs = await getListAsync();
    var filteredItems =
        allLibs.where((item) {
          String title = removeDiacritics(item.title).toLowerCase();
          return title.contains(keyword) ||
              item.title.toLowerCase().contains(keyword);
        }).toList();

    return filteredItems;
  }

  Future<void> reorderMusicsInLibrary({
    required int libraryId,
    required List<int> musicIds,
  }) async {
    var db = await _db;
    var batch = db.batch();
    batch.delete(
      DbTable.musicLibrary,
      where: 'libraryId = ?',
      whereArgs: [libraryId],
    );
    for (var i = 0; i < musicIds.length; i++) {
      batch.insert(
        DbTable.musicLibrary,
        MusicLibrary(musicId: musicIds[i], libraryId: libraryId).toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
