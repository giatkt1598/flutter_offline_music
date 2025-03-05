import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter_offline_music/models/music.dart';
import 'package:flutter_offline_music/models/music_folder.dart';
import 'package:flutter_offline_music/services/database_helper.dart';
import 'package:flutter_offline_music/services/db_table.dart';
import 'package:flutter_offline_music/utilities/debug_helper.dart';
import 'package:flutter_offline_music/utilities/find_nonsilent_position.dart';
import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:remove_diacritic/remove_diacritic.dart';
import 'package:sqflite/sqlite_api.dart';

class MusicService {
  static const String tableMusicFolder = 'MusicFolder';
  static const String tableMusic = 'Music';
  static const List<String> musicFormats = [
    '.mp3', // MP3 - Phổ biến nhất
    '.m4a', // MPEG-4 Audio
    '.wma', // Windows Media Audio
    '.flac', // Free Lossless Audio Codec (Không mất dữ liệu)
    '.wav', // Waveform Audio File Format
    '.aac', // Advanced Audio Codec
    '.ogg', // Ogg Vorbis
    '.opus', // Opus - Hiệu suất cao
    '.aiff', // Audio Interchange File Format
    '.alac', // Apple Lossless Audio Codec
    '.dsd', // Direct Stream Digital
    '.pcm', // Pulse Code Modulation
    '.amr', // Adaptive Multi-Rate (dùng cho ghi âm)
    '.mid', // MIDI (dùng cho nhạc cụ điện tử)
    '.mp2', // MPEG Layer II (dùng trong phát sóng)
  ];

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<int> insertMusicFolderAsync(MusicFolder model) async {
    var values = model.toJson();
    values['id'] = null;
    return await (await _db).insert(
      tableMusicFolder,
      values,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> updateMusicFolderAsync(MusicFolder model) async {
    var values = model.toJson();
    return await (await _db).update(
      tableMusicFolder,
      values,
      where: 'id = ?',
      whereArgs: [model.id],
    );
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

  Future<List<MusicFolder>> getMusicFolderListAsync({
    String? orderBy,
    bool? isHidden = false,
  }) async {
    var whereBuilt = DatabaseHelper.buildQueryFilter({
      'isHidden = ?': isHidden,
    });
    var queryRs = await (await _db).query(
      tableMusicFolder,
      where: whereBuilt.where,
      whereArgs: whereBuilt.whereArgs,
      orderBy: orderBy,
    );
    var list = queryRs.map((e) => MusicFolder.fromJson(e)).toList();

    var musics = await getListMusicAsync(isHidden: isHidden);

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
    await (await _db).insert(
      tableMusic,
      values,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> updateMusicAsync(Music model) async {
    var values = model.toJson();
    return await (await _db).update(
      DbTable.music,
      values,
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> updateMusicPlayedLastTime(String musicPath) async {
    return await (await _db).rawUpdate(
      'UPDATE ${DbTable.music} SET playedLastTime = ? WHERE path = ?',
      [DateTime.now().toIso8601String(), musicPath],
    );
  }

  Future<int> increaseMusicPlayedCount(String musicPath) async {
    final playedCount = (await getMusicAsync(path: musicPath)).playedCount;
    return await (await _db).rawUpdate(
      'UPDATE ${DbTable.music} SET playedCount = ? WHERE path = ?',
      [playedCount + 1, musicPath],
    );
  }

  Future<int> deleteMusicAsync(int id) async {
    return await (await _db).delete(
      DbTable.music,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Music> getMusicAsync({String? path}) async {
    var list = await (await _db).query(
      DbTable.music,
      where: 'path = ?',
      whereArgs: [path],
    );

    return Music.fromJson(list.first);
  }

  Future<List<Music>> getListMusicAsync({
    int? musicFolderId,
    String? orderBy,
    bool? isHidden = false,
  }) async {
    final db = await _db;
    var queryRs = await db.rawQuery(
      '''
SELECT ${DbTable.music}.*
FROM ${DbTable.music} JOIN ${DbTable.musicFolder} ON ${DbTable.music}.musicFolderId = ${DbTable.musicFolder}.id
WHERE (:isHidden IS NULL OR :isHidden = 1 OR ${DbTable.musicFolder}.isHidden = 0)
  AND (:isHidden IS NULL OR ${DbTable.music}.isHidden = :isHidden)
  AND (:musicFolderId IS NULL OR ${DbTable.music}.musicFolderId = :musicFolderId)
${orderBy != null ? 'ORDER BY $orderBy' : ''}
'''
          .replaceAll(
            ':isHidden',
            isHidden == null
                ? 'NULL'
                : isHidden == true
                ? '1'
                : '0',
          )
          .replaceAll(':musicFolderId', musicFolderId.toString()),
    );
    var list = queryRs.map((e) => Music.fromJson(e)).toList();
    return list;
  }

  List<String> getMusicFiles(String filePath) {
    var dir = Directory(filePath);
    var files = dir.listSync();

    return files
        .where((x) => musicFormats.any((f) => x.path.endsWith(f)))
        .map((x) => x.path)
        .toList();
  }

  Future<List<String>> getMusicFoldersInStorageAsync({
    String folderPath = '/storage/emulated/0',
  }) async {
    List<String> result = [];
    List<String> blacklist = ['/storage/emulated/0/Android'];
    if (blacklist.contains(folderPath)) return result;
    Directory directory = Directory(folderPath);
    if (await directory.exists()) {
      for (var element in directory.listSync()) {
        var type = await FileSystemEntity.type(element.path);
        bool isMusicFile =
            type == FileSystemEntityType.file &&
            musicFormats.any(
              (x) => element.path.toLowerCase().endsWith(x.toLowerCase()),
            );
        if (isMusicFile) {
          result.add(element.parent.path);
        } else if (type == FileSystemEntityType.directory) {
          result.addAll(
            await getMusicFoldersInStorageAsync(folderPath: element.path),
          );
        }
      }
      return result.toSet().toList(); // Lists all files and folders
    } else {
      throw Exception("Folder does not exist");
    }
  }

  Future<List<MusicFolder>> scanMusicAsync({
    Function(String path)? onProgress,
    Function(int totalNewFile, int totalDeletedFile)? onCompleted,
  }) async {
    int addedFileCount = 0;
    int removedFileCount = 0;
    final progressStream = StreamController<String>();
    if (onProgress != null) {
      progressStream.stream.listen((path) {
        onProgress(path);
      });
    }
    List<String> musicFolderPaths = await getMusicFoldersInStorageAsync();
    final oldFolders = await getMusicFolderListAsync(isHidden: null);
    final oldMusics = await getListMusicAsync(isHidden: null);

    final notFoundFolders =
        oldFolders
            .where((old) => !musicFolderPaths.contains(old.path))
            .toList();

    for (var folder in notFoundFolders) {
      await deleteMusicFolderAsync(folder.id);
    }

    for (String musicFolderPath in musicFolderPaths) {
      String dirName = musicFolderPath.substring(
        musicFolderPath.lastIndexOf('/') + 1,
      );
      int musicFolderId =
          oldFolders.where((x) => x.path == musicFolderPath).firstOrNull?.id ??
          await insertMusicFolderAsync(
            MusicFolder(id: 0, path: musicFolderPath, name: dirName),
          );

      var musicPaths = getMusicFiles(musicFolderPath);

      final notFoundMusics = oldMusics.where(
        (old) =>
            old.musicFolderId == musicFolderId &&
            !musicPaths.contains(old.path),
      );

      removedFileCount += notFoundMusics.length;

      for (var item in notFoundMusics) {
        await deleteMusicAsync(item.id);
      }

      for (String musicPath in musicPaths) {
        String fileName = musicPath.substring(
          musicPath.lastIndexOf('/') + 1,
          musicPath.lastIndexOf('.'),
        );

        bool isNew = !oldMusics.any((x) => x.path == musicPath);
        if (isNew) addedFileCount++;
        final metadata = readMetadata(File(musicPath));
        await insertMusicAsync(
          Music(
            id: 0,
            musicFolderId: musicFolderId,
            title: metadata.title ?? fileName,
            path: musicPath,
            artist: metadata.artist,
            genre: metadata.genres.join(', '),
            lengthInSecond: metadata.duration?.inSeconds ?? 0,
            creationTime: (await File(musicPath).stat()).changed,
          ),
        );
        progressStream.add(musicPath);
      }
    }
    var list = await getMusicFolderListAsync();
    if (onCompleted != null) {
      onCompleted(addedFileCount, removedFileCount);
    }
    return list;
  }

  static bool _isFetchedSkipSilent = false;
  @Deprecated('Crash app')
  fetchSkipSilentDurations() async {
    if (_isFetchedSkipSilent) return;
    _isFetchedSkipSilent = true;
    var musics = await getListMusicAsync(isHidden: null);
    musics =
        musics
            .where((x) => x.skipSilentStart == null && x.skipSilentEnd == null)
            .toList();
    logDebug('Start fetchSkipSilentDurations');
    for (var music in musics) {
      var result = await findNonSilentPosition(music.path);
      if (result != null) {
        logDebug(
          'Update skip silent: ${music.path} start: ${result.start} end: ${result.end}',
        );
        music.skipSilentStart = result.start.inMilliseconds;
        music.skipSilentEnd = result.end.inMilliseconds;
        await updateMusicAsync(music);
      }
    }
    logDebug('End fetchSkipSilentDurations');
  }

  String calcTotalDuration(List<Music> list) {
    int totalDurationInSeconds =
        list.isEmpty
            ? 0
            : list.map((m) => m.lengthInSecond).reduce((a, b) => a + b);
    return fDurationLong(Duration(seconds: totalDurationInSeconds));
  }

  Future<List<Music>> searchMusics(String keyword) async {
    if (keyword.isEmpty) return [];

    var allMusics = await getListMusicAsync(
      orderBy: 'title asc',
      isHidden: null,
    );
    keyword = keyword.toLowerCase();
    var filteredItems =
        allMusics.where((item) {
          String title = removeDiacritics(item.title).toLowerCase();
          String artist =
              item.artist != null
                  ? removeDiacritics(item.artist!).toLowerCase()
                  : '';
          return title.contains(keyword) ||
              artist.contains(keyword) ||
              item.title.toLowerCase().contains(keyword) ||
              item.artist?.toLowerCase().contains(keyword) == true;
        }).toList();

    return filteredItems;
  }

  Future<List<MusicFolder>> searchFolders(String keyword) async {
    if (keyword.isEmpty) return [];

    keyword = keyword.toLowerCase();
    var allFolders = await getMusicFolderListAsync(
      orderBy: 'name asc',
      isHidden: null,
    );

    var filteredItems =
        allFolders.where((item) {
          String name = removeDiacritics(item.name).toLowerCase();
          return name.contains(keyword) ||
              item.name.toLowerCase().contains(keyword);
        }).toList();

    return filteredItems;
  }
}
