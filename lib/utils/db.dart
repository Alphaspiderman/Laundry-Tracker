import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:clothes_tracker/models/dbEntry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  late Database _database;

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
            image_path TEXT,
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

    // Insert data into the database
    await _database.insert('your_table', {
      'name': data.name,
      'state': data.state,
      'image_path': imagePath,
    });
  }

  Future<List<ItemCard>> fetchData() async {
    final List<Map<String, dynamic>> maps = await _database.query('clothes');

    return List.generate(maps.length, (index) {
      return ItemCard.fromMap(maps[index]);
    });
  }

  Future<List<ItemCard>> fetchDataByState(int state) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'clothes',
      where: 'state = ?',
      whereArgs: [state],
    );

    return List.generate(maps.length, (index) {
      return ItemCard.fromMap(maps[index]);
    });
  }

  Future<void> updateData(ItemCard data) async {
    await _database.update(
      'clothes',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  // Update Image Path
  Future<void> updateImagePath(String id, String imagePath) async {
    await _database.update(
      'clothes',
      {'image_path': imagePath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a card
  Future<void> deleteData(String id) async {
    await _database.delete(
      'clothes',
      where: 'id = ?',
      whereArgs: [id],
    );

    final appDir = await getApplicationDocumentsDirectory();
    final imagePath = join(appDir.path, 'images', '$id.png');
    await File(imagePath).delete();
  }
}
