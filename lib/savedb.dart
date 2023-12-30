import 'dart:async';
// import 'dart:io';
import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MusicDatabaseHelper {
  static Database? _database;
  static const String tableName = 'saved_music';

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // If _database is null, initialize it
    await initDatabase();
    return _database!;
  }

  static Future<void> initDatabase() async {
  if (_database != null) {
    return;
  }

  // Set the database factory before opening the database
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Get the document directory
  final documentsDirectory = await getDatabasesPath();
  final path = join(documentsDirectory, 'music_database.db');

  // Open/create the database at a given path
  _database = await databaseFactoryFfi.openDatabase(path, options: OpenDatabaseOptions(
    version: 1,
    onCreate: (db, version) async {
      // Create the 'saved_music' table
      await db.execute('''
        CREATE TABLE $tableName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          image TEXT,
          audio TEXT,
          description TEXT
        )
      ''');
    },
  ));

  // Ensure the database is open before returning
  if (_database!.isOpen) {
    return;
  } else {
    throw Exception("Failed to open the database");
  }
}



  static Future<void> insertMusic(Map<String, dynamic> music) async {
    final db = await database;
    await db.insert(tableName, music,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getAllSavedMusic() async {
    final db = await database;
    return await db.query(tableName);
  }

  static Future<Map<String, dynamic>?> getSavedMusic(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }
}