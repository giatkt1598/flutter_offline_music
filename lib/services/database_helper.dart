import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final String _databaseName = 'g_player.db';
  static Database? _database;

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    await deleteDatabase(path);
    _database = await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    // delete database to debug
    // await deleteDatabase(path);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE MusicFolder(
id INTEGER PRIMARY KEY AUTOINCREMENT
, path TEXT NOT NULL
, name TEXT NOT NULL);
          ''');

        await db.execute('''
CREATE TABLE Music(
id INTEGER PRIMARY KEY AUTOINCREMENT
, musicFolderId INTEGER
, title TEXT NOT NULL
, path TEXT NOT NULL
, artist TEXT
, lengthInSecond INTEGER
, thumbnail TEXT
, genre TEXT
, creationTime TEXT
, FOREIGN KEY (musicFolderId) REFERENCES MusicFolder(id) ON DELETE CASCADE);
          ''');
      },
    );
  }
}
