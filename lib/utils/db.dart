import 'dart:io';

import 'package:clothes_tracker/models/state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:clothes_tracker/models/db_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static Directory? appDir;

  Future<Database> get database async {
    appDir = await getApplicationDocumentsDirectory();
    if (_database != null) return _database!;
    await initDatabase();
    return _database!;
  }

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'data.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE clothes (
            id INTEGER PRIMARY KEY,
            name TEXT,
            state INTEGER,
            image_path TEXT
          )
          ''',
        );
      },
      version: 1,
    );
  }

  Future<void> insertData(DbEntry data, File imageFile) async {
    // Save image to local directory
    final imagePath = join(appDir!.path, 'images', data.imagePath);
    await imageFile.copy(imagePath);
    // Delete the temp image
    await imageFile.delete();

    // Clean image path
    final imagePathClean = imagePath.replaceAll(appDir!.path, '');

    Database db = await database;

    // Insert data into the database
    await db.insert('clothes', {
      'name': data.name,
      'state': data.state.index,
      'image_path': imagePathClean,
    });
  }

  Future<List<DbEntry>> fetchData() async {
    Database db = await database;
    // Query for all entries
    final List<Map<String, dynamic>> maps = await db.query('clothes');

    return generateList(maps);
  }

  Future<List<DbEntry>> fetchDataByState(States state) async {
    int dbState = state.index;
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clothes',
      where: 'state = ?',
      whereArgs: [dbState],
    );

    return generateList(maps);
  }

  // Update State
  Future<void> updateState(int id, States state) async {
    Database db = await database;
    int dbState = state.index;
    await db.update(
      'clothes',
      {'state': dbState},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a card
  Future<void> deleteData(String id) async {
    Database db = await database;
    // Get the data to delete
    final data = await db.query(
      'clothes',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Convert to DbEntry
    final dataEntry = DbEntry.fromMap(data[0]);
    // Delete the data
    await db.delete(
      'clothes',
      where: 'id = ?',
      whereArgs: [id],
    );

    final appDir = await getApplicationDocumentsDirectory();
    final imagePath = join(appDir.path, '${dataEntry.imagePath}.png');
    await File(imagePath).delete();
  }

  // Purge the database
  Future<void> purgeData() async {
    Database db = await database;
    await db.delete('clothes');
    final imagePath = join(appDir!.path, 'images');
    // Delete the images directory
    await Directory(imagePath).delete(recursive: true);
    // Recreate the images directory
    await Directory(imagePath).create();
  }

  List<DbEntry> generateList(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (index) {
      // Create a editable copy of the map
      var map = Map<String, dynamic>.from(maps[index]);
      map.addEntries([MapEntry('prepend', appDir!.path)]);
      return DbEntry.fromMap(map);
    });
  }
}
