import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Databasehelper {
  static const _databasename = 'music_database.db';
  static const _databaseversion = 1;
  static const table = 'music_records';
  static const columnID = 'id';
  static const columnName = 'name';
  static const columnImage = 'image';
  static const columnAudio = 'audio';
  static const columnDescription = 'description';

  Databasehelper._privateConstructor();
  static final Databasehelper instance = Databasehelper._privateConstructor();

  Future<Database> get database async {
    return await _initDatabase();
  }

  Future _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, _databasename);
    return await openDatabase(path, version: _databaseversion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnID INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnImage TEXT NOT NULL,
        $columnAudio TEXT NOT NULL,
        $columnDescription TEXT
      )
    ''');
  }

  Future<int> insertMusic(Map<String, dynamic> music) async {
    Database db = await instance.database;
    return await db.insert(table, music, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(table);
  }
}
