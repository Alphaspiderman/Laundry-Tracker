import 'dart:convert';
import 'dart:io';

import 'package:clothes_tracker/models/db_entry.dart';
import 'package:clothes_tracker/models/state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static Directory? appDir;
  static Logger log = Get.find();

  Future<Database> get database async {
    appDir = await getApplicationDocumentsDirectory();
    if (_database != null) return _database!;
    await initDatabase();
    return _database!;
  }

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<void> initClass() async {
    appDir = await getApplicationDocumentsDirectory();
    await initDatabase();
  }

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
    log.i("Database initialized");
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
    await db.insert(
      'clothes',
      {
        'name': data.name,
        'state': data.state.index,
        'image_path': imagePathClean,
      },
    );
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
  Future<void> deleteData(int id) async {
    Database db = await database;
    // Get the data to delete
    final data = await db.query(
      'clothes',
      where: 'id = ?',
      whereArgs: [id],
    );
    log.d("Data to delete: $data");
    // Get the image path
    var map = Map<String, dynamic>.from(data[0]);
    map.addEntries([MapEntry('prepend', appDir!.path)]);
    // Convert to DbEntry
    final dataEntry = DbEntry.fromMap(map);
    // Delete the data
    await db.delete(
      'clothes',
      where: 'id = ?',
      whereArgs: [id],
    );
    await File(dataEntry.imagePath).delete();
  }

  // Import data
  Future<void> importData(File file) async {
    // Purge the database
    await purgeData();

    // Extract the ZIP file
    await ZipFile.extractToDirectory(
      zipFile: file,
      destinationDir: Directory(join(appDir!.path, "import")),
    );

    // Declare the directory for the imported data
    final importDir = Directory(join(appDir!.path, "import"));
    final importFile = File(join(importDir.path, "data.json"));

    // Read JSON file and get a list
    final data = await importFile.readAsString();
    List jsondata = json.decode(data);

    // Convert to List
    List<DbEntry> dataList = jsondata.map((e) => DbEntry.fromJson(e)).toList();

    // Declare the directory for images
    final imagesDir = Directory(join(appDir!.path, "images"));
    final importImagesDir = Directory(importDir.path);

    // Create directory if it doesn't exist
    if (!imagesDir.existsSync()) {
      await imagesDir.create(recursive: true);
    }

    Database db = await database;
    // Insert data into the database and copy image
    for (DbEntry data in dataList) {
      await db.insert('clothes', {
        'name': data.name,
        'state': data.state.index,
        'image_path': data.imagePath,
      });

      final importImagePath = importImagesDir.path + data.imagePath;
      final saveImagePath = appDir!.path + data.imagePath;
      await File(importImagePath).copy(saveImagePath);
    }

    // Delete the import directory
    await importDir.delete(recursive: true);

    Get.back();
    Get.snackbar("Import", "Data Imported!");
  }

  // Export data as a ZIP
  Future<void> exportData() async {
    // Log
    log.d("Exporting data");
    // Declare folder for export
    final exportDir = Directory(join(appDir!.path, "export"));
    final exportImagesDir = Directory(join(exportDir.path, "images"));

    // Delete directory if it exists
    if (exportDir.existsSync()) {
      await exportDir
          .delete(recursive: true)
          .then((value) => log.d("Deleted old export folder"));
    }
    // Create directory
    await exportImagesDir.create(recursive: true);

    // Get database
    Database db = await database;

    // Query for all entries
    final List<Map<String, dynamic>> maps = await db.query('clothes');
    List<DbEntry> dataList = generateList(maps, prepend: false);

    // Convert to JSON
    String jsonData = jsonEncode(dataList.map((e) => e.toJson()).toList());

    // Write JSON to file
    final exportFile = File(join(exportDir.path, "data.json"));
    await exportFile.writeAsString(jsonData);

    // Declare the directory for images
    final imagesDir = Directory(join(appDir!.path));

    // Copy all images to export directory
    for (var data in dataList) {
      // Declare the path for the image
      String exportImagePath = exportDir.path + data.imagePath;

      // Access file to copy
      File f = File(imagesDir.path + data.imagePath);

      log.d(f.path);
      log.d(exportImagePath);

      // Copy the file
      if (await f.exists()) {
        await f.copy(exportImagePath);
      } else {
        log.d(f.path);
      }
    }

    // Create a ZIP file
    final zipFile = File(join(appDir!.path, "export.zip"));
    await ZipFile.createFromDirectory(
      sourceDir: exportDir,
      zipFile: zipFile,
    );

    // Delete the export directory
    await exportDir.delete(recursive: true);

    // Ask where to save the file
    final saveFilePath = await FilePicker.platform.getDirectoryPath();
    if (saveFilePath == null) {
      // User canceled the picker
      return;
    }
    // Declare file to save
    String now = DateTime.now().toString().split(".")[0].replaceAll(":", "-");
    File saveFile = File(join(saveFilePath, "export-$now.zip"));
    // Save File
    await zipFile.copy(saveFile.path);
    // Delete the temp file
    await zipFile.delete();
    Get.snackbar("Export", "Data Exported!");
  }

  // Purge the database
  Future<void> purgeData() async {
    Database db = await database;
    await db.delete('clothes');
    final imagePath = join(appDir!.path, 'images');
    // Check if images directory exists
    if (Directory(imagePath).existsSync()) {
      // Delete the images directory
      await Directory(imagePath).delete(recursive: true);
    }
    // Recreate the images directory
    await Directory(imagePath).create();
  }

  // Generate a list of DbEntry from a list of maps
  List<DbEntry> generateList(List<Map<String, dynamic>> maps,
      {bool prepend = true}) {
    return List.generate(maps.length, (index) {
      // Create a editable copy of the map
      var map = Map<String, dynamic>.from(maps[index]);
      map.addEntries([MapEntry('prepend', prepend ? appDir!.path : '')]);
      return DbEntry.fromMap(map);
    });
  }

  // Get Stats
  Future<Map<String, int>> getStats() async {
    Database db = await database;
    // Query for all entries
    final List<Map<String, dynamic>> maps = await db.query('clothes');

    // Generate a list of DbEntry
    List<DbEntry> dataList = generateList(maps, prepend: false);

    // Declare the map
    Map<String, int> stats = {
      "Total": 0,
      "Closet": 0,
      "Basket": 0,
      "Wash": 0,
    };

    // Count the number of items in each state
    for (var data in dataList) {
      stats["Total"] = stats["Total"]! + 1;
      switch (data.state) {
        case States.closet:
          stats["Closet"] = stats["Closet"]! + 1;
          break;
        case States.basket:
          stats["Basket"] = stats["Basket"]! + 1;
          break;
        case States.wash:
          stats["Wash"] = stats["Wash"]! + 1;
          break;
      }
    }

    return stats;
  }
}
