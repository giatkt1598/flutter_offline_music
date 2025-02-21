import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'g_player.db');
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
, name TEXT NOT NULL
, path TEXT NOT NULL
, author TEXT
, lengthInSecond INTEGER
, FOREIGN KEY (musicFolderId) REFERENCES MusicFolder(id) ON DELETE CASCADE);
          ''');
      },
    );
  }
}
