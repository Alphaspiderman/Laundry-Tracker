import 'dart:io';

import 'package:clothes_tracker/models/state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:clothes_tracker/models/db_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
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

  Future<void> insertData(ItemCard data, File imageFile) async {
    // Save image to local directory
    final appDir = await getApplicationDocumentsDirectory();
    final imagePath = join(appDir.path, 'images', '${data.imagePath}.png');
    await imageFile.copy(imagePath);

    Database db = await database;

    // Insert data into the database
    await db.insert('clothes', {
      'name': data.name,
      'state': data.state,
      'image_path': imagePath,
    });
  }

  Future<List<ItemCard>> fetchData() async {
    Database db = await database;
    // Query for all entries
    final List<Map<String, dynamic>> maps = await db.query('clothes');

    return List.generate(maps.length, (index) {
      print(maps[index]);
      return ItemCard.fromMap(maps[index]);
    });
  }

  Future<List<ItemCard>> fetchDataByState(States state) async {
    int dbState = state.index;
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clothes',
      where: 'state = ?',
      whereArgs: [dbState],
    );

    return List.generate(maps.length, (index) {
      return ItemCard.fromMap(maps[index]);
    });
  }

  Future<void> updateData(ItemCard data) async {
    Database db = await database;
    await db.update(
      'clothes',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  // Update Image Path
  Future<void> updateImagePath(String id, String imagePath) async {
    Database db = await database;
    await db.update(
      'clothes',
      {'image_path': imagePath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a card
  Future<void> deleteData(String id) async {
    Database db = await database;
    await db.delete(
      'clothes',
      where: 'id = ?',
      whereArgs: [id],
    );

    final appDir = await getApplicationDocumentsDirectory();
    final imagePath = join(appDir.path, 'images', '$id.png');
    await File(imagePath).delete();
  }

  // Purge the database
  Future<void> purgeData() async {
    Database db = await database;
    await db.delete('clothes');
  }
}
