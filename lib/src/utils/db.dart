import 'dart:convert';
import 'dart:io';

import 'package:clothes_tracker/src/models/category.dart';
import 'package:clothes_tracker/src/models/db_entry.dart';
import 'package:clothes_tracker/src/models/state.dart';
import 'package:clothes_tracker/src/utils/list_controller.dart';
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

  Future<void> refreshCategory() async {
    // Check if the category list is in GetX
    if (!Get.isRegistered<List<Category>>()) {
      return;
    }
    List<Category> categories = Get.find();
    // Load categories from database
    List<Category> dbCategories = await fetchCategories();
    // Replace the old list with the new list
    categories.assignAll(dbCategories);
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
            category_id INTEGER
          )
          ''',
        );
        // Create the table to track quantity of misc_clothes
        db.execute(
          '''
          CREATE TABLE misc_clothes (
            id INTEGER PRIMARY KEY,
            name TEXT,
            closet INTEGER DEFAULT 0,
            basket INTEGER DEFAULT 0,
            wash INTEGER DEFAULT 0,
            total INTEGER DEFAULT 0,
            CHECK (total = closet + basket + wash)
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
          // Insert the misc_clothes table
          db.execute(
            '''
              CREATE TABLE misc_clothes (
                id INTEGER PRIMARY KEY,
                name TEXT,
                closet INTEGER DEFAULT 0,
                basket INTEGER DEFAULT 0,
                wash INTEGER DEFAULT 0,
                total INTEGER DEFAULT 0,
                CHECK (total = closet + basket + wash)
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
    // Check if the default category exists
    if (!await checkCategory("Default")) {
      // Insert the default category
      await addCategory("Default");
    }
    // Check if the misc_clothes table is empty
    final List<Map<String, dynamic>> miscClothes =
        await _database!.query('misc_clothes');
    if (miscClothes.isEmpty) {
      // Insert default values
      await _database!.insert('misc_clothes', {
        'name': 'Top Innerwear',
      });
      await _database!.insert('misc_clothes', {
        'name': 'Bottom Innerwear',
      });
      await _database!.insert('misc_clothes', {
        'name': 'Socks',
      });
    }
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

  // Fetch data by category
  Future<List<DbEntry>> fetchDataByCategory(int categoryId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clothes',
      where: 'category_id = ?',
      whereArgs: [categoryId],
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

  // Update Category
  Future<void> updateCategory(int id, int categoryId) async {
    Database db = await database;
    await db.update(
      'clothes',
      {'category_id': categoryId},
      where: 'id = ?',
      whereArgs: [id],
    );
    await refreshCategory();
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

  // Add a category
  Future<void> addCategory(String name) async {
    Database db = await database;
    // Insert the category
    await db.insert(
      'categories',
      {
        'name': name,
      },
    );
    await refreshCategory();
  }

  // Fetch all categories
  Future<List<Category>> fetchCategories() async {
    Database db = await database;
    // Query for all categories
    final List<Map<String, dynamic>> maps = await db.query('categories');
    log.i("Categories: $maps");
    // Convert to List of Category
    return List.generate(maps.length, (index) {
      return Category(
        id: maps[index]['id'],
        name: maps[index]['name'],
      );
    });
  }

  // Check if a category exists
  Future<bool> checkCategory(String text) {
    Database db = _database!;
    // Query for the category
    return db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [text],
    ).then((value) {
      // If the category exists, return true
      if (value.isNotEmpty) {
        return true;
      }
      // If the category doesn't exist, return false
      return false;
    });
  }

  // Delete a category
  Future<bool> deleteCategory(int id) async {
    // Make sure its not the default category
    if (id == 1) {
      return false;
    }
    Database db = await database;
    // Delete the category
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Update the category_id of all entries with the deleted category
    await db.update(
      'clothes',
      {'category_id': 1},
      where: 'category_id = ?',
      whereArgs: [id],
    );
    await refreshCategory();
    return true;
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
    final importMiscClothesFile =
        File(join(importDir.path, "misc_clothes.json"));

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
        // Prevent the default category from being imported
        if (category['id'] == 1) {
          continue;
        }
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

    // Check if the misc_clothes export file exists
    if (importMiscClothesFile.existsSync()) {
      // Read JSON file and get a list of maps
      final miscClothesData = await importMiscClothesFile.readAsString();
      List jsonMiscClothes = json.decode(miscClothesData);
      // Save the categories to the database
      for (var miscClothes in jsonMiscClothes) {
        await db.insert(
          'misc_clothes',
          {
            'id': miscClothes['id'],
            'name': miscClothes['name'],
            'closet': miscClothes['closet'],
            'basket': miscClothes['basket'],
            'wash': miscClothes['wash'],
            'total': miscClothes['total'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Set autoincrement to the next available ID
      await db.execute(
          "UPDATE SQLITE_SEQUENCE SET SEQ=MAX(id) WHERE NAME='misc_clothes'");
    } else {
      // Insert default values
      await db.insert('misc_clothes', {
        'name': 'Top Innerwear',
      });
      await db.insert('misc_clothes', {
        'name': 'Bottom Innerwear',
      });
      await db.insert('misc_clothes', {
        'name': 'Socks',
      });
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

    // Query for all misc_clothes
    final List<Map<String, dynamic>> miscClothes =
        await db.query('misc_clothes');

    // Convert to JSON
    String jsonMiscClothes =
        jsonEncode(miscClothes.map((e) => e).toList()).toString();

    // Write JSON to file
    final exportMiscClothesFile =
        File(join(exportDir.path, "misc_clothes.json"));

    await exportMiscClothesFile.writeAsString(jsonMiscClothes);

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
    // Refresh the category list
    await refreshCategory();
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

  Future<void> updateName(int id, String value) async {
    // Update the name for the entry
    Database db = await database;

    await db.update(
      'clothes',
      {'name': value},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
