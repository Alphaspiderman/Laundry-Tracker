import 'dart:convert';
import 'dart:io';

import 'package:clothes_tracker/models/db_entry.dart';
import 'package:clothes_tracker/models/state.dart';
import 'package:clothes_tracker/utils/list_controller.dart';
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

  // Function to refresh all list controllers
  void refreshAll() {
    Get.find<ListController>(tag: "basket").refreshData(States.basket);
    Get.find<ListController>(tag: "closet").refreshData(States.closet);
    Get.find<ListController>(tag: "laundry").refreshData(States.laundry);
  }

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'data.db'),
      onCreate: (db, version) {
        db.execute(
          // Create the table to hold infomration about the categories
          '''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY,
            name TEXT
          )
          ''',
        );
        // Create the table to hold information about the clothes
        db.execute(
          '''
          CREATE TABLE clothes (
            id INTEGER PRIMARY KEY,
            name TEXT,
            state INTEGER,
            image_path TEXT,
            category_id INTEGER,
          )
          ''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // Log the old and new versions
        log.i("Upgrading database from $oldVersion to $newVersion");
        if (oldVersion < 2) {
          // Add the category_id column and set it to 0 for all entries (default category)
          db.execute(
            '''
            ALTER TABLE clothes
            ADD COLUMN category_id INTEGER DEFAULT 1
            ''',
          );
          // Add the categories table
          db.execute(
            '''
            CREATE TABLE categories (
              id INTEGER PRIMARY KEY,
              name TEXT
            )
            ''',
          );
          // Insert the default category
          db.insert(
            'categories',
            {
              'name': 'Default',
            },
          );
        }
      },
      version: 2,
    );
    // Insert the default category
    _database!.insert(
      'categories',
      {
        'name': 'Default',
      },
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
        'category_id': data.categoryId,
      },
    );
    // Refresh all list controllers
    refreshAll();
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
    final importCategoriesFile = File(join(importDir.path, "categories.json"));
    final importDataFile = File(join(importDir.path, "data.json"));

    // Read JSON file and get a list of maps
    final clothesData = await importDataFile.readAsString();
    List jsondata = json.decode(clothesData);

    // Get database
    Database db = await database;

    // Declare the list of DbEntry
    List<DbEntry> dataList = [];

    // Check if the categories file exists
    if (importCategoriesFile.existsSync()) {
      // Read JSON file and get a list of maps
      final categoriesData = await importCategoriesFile.readAsString();
      List jsonCategories = json.decode(categoriesData);
      // Save the categories to the database
      for (var category in jsonCategories) {
        await db.insert('categories', {
          'id': category['id'],
          'name': category['name'],
        });
      }

      // Set autoincrement to the next available ID
      await db.execute(
          "UPDATE SQLITE_SEQUENCE SET SEQ=MAX(id) WHERE NAME='categories'");

      // Convert to List of DbEntry
      dataList = jsondata.map((e) => DbEntry.fromJson(e)).toList();
    } else {
      // Set the category_id to 1 for all entries
      for (var data in jsondata) {
        data['categoryId'] = 1;
      }
      // Convert to List of DbEntry
      dataList = jsondata.map((e) => DbEntry.fromJson(e)).toList();
    }

    // Declare the directory for images
    final imagesDir = Directory(join(appDir!.path, "images"));
    final importImagesDir = Directory(importDir.path);

    // Create directory if it doesn't exist
    if (!imagesDir.existsSync()) {
      await imagesDir.create(recursive: true);
    }

    // Insert data into the database and copy image
    for (DbEntry data in dataList) {
      await db.insert('clothes', {
        'name': data.name,
        'state': data.state.index,
        'image_path': data.imagePath,
        'category_id': data.categoryId,
      });

      final importImagePath = importImagesDir.path + data.imagePath;
      final saveImagePath = appDir!.path + data.imagePath;
      await File(importImagePath).copy(saveImagePath);
    }

    // Delete the import directory
    await importDir.delete(recursive: true);

    Get.back();
    Get.snackbar("Import", "Data Imported!");
    // Refresh all list controllers
    refreshAll();
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

    // Query for all categories
    final List<Map<String, dynamic>> categories = await db.query('categories');

    // Convert to JSON
    String jsonCategories =
        jsonEncode(categories.map((e) => e).toList()).toString();

    // Write JSON to file
    final exportCategoriesFile = File(join(exportDir.path, "categories.json"));
    await exportCategoriesFile.writeAsString(jsonCategories);

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

    // Create a file to hold the database version number
    final versionFile = File(join(exportDir.path, "version.txt"));
    // Get the database version
    final version = await db.getVersion();
    // Write the version number to the file
    await versionFile.writeAsString(version.toString());

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
    // Delete all entries
    await db.delete('clothes');
    await db.delete('categories');
    // Delete the images directory
    final imagePath = join(appDir!.path, 'images');
    // Check if images directory exists
    if (Directory(imagePath).existsSync()) {
      // Delete the images directory
      await Directory(imagePath).delete(recursive: true);
    }
    // Recreate the images directory
    await Directory(imagePath).create();
    // Recreate the database
    await initDatabase();
    // Refresh all list controllers
    refreshAll();
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
        case States.laundry:
          stats["Wash"] = stats["Wash"]! + 1;
          break;
      }
    }

    return stats;
  }
}
