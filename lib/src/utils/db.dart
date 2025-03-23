import 'dart:convert';
import 'dart:io';

import 'package:clothes_tracker/src/models/category.dart';
import 'package:clothes_tracker/src/models/db_exception.dart';
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

  // ----------------------------------------------------------------
  // Database Setup
  // ----------------------------------------------------------------

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
        db.execute(
          // Create the table to hold infomration about the categories
          '''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
          ''',
        );
        // Create the table to hold information about the clothes
        db.execute(
          '''
          CREATE TABLE clothes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
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
            id INTEGER PRIMARY KEY AUTOINCREMENT,
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
        // Migration from version 1 to 2
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
                id INTEGER PRIMARY KEY AUTOINCREMENT,
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

        // Migration from version 2 to 3
        if (oldVersion < 3) {
          // Create temp table for clothes
          db.execute(
            '''
            CREATE TABLE clothes_temp (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              state INTEGER,
              image_path TEXT,
              category_id INTEGER
            )
            ''',
          );
          // Copy data from clothes to clothes_temp
          db.execute(
            '''
            INSERT INTO clothes_temp (id, name, state, image_path, category_id)
            SELECT id, name, state, image_path, category_id
            FROM clothes
            ''',
          );
          // Drop the clothes table
          db.execute(
            '''
            DROP TABLE clothes
            ''',
          );
          // Rename the clothes_temp table to clothes
          db.execute(
            '''
            ALTER TABLE clothes_temp
            RENAME TO clothes
            ''',
          );

          // Create temp table for misc_clothes
          db.execute(
            '''
            CREATE TABLE misc_clothes_temp (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              closet INTEGER DEFAULT 0,
              basket INTEGER DEFAULT 0,
              wash INTEGER DEFAULT 0,
              total INTEGER DEFAULT 0,
              CHECK (total = closet + basket + wash)
            )
            ''',
          );

          // Copy data from misc_clothes to misc_clothes_temp
          db.execute(
            '''
            INSERT INTO misc_clothes_temp (id, name, closet, basket, wash, total)
            SELECT id, name, closet, basket, wash, total
            FROM misc_clothes
            ''',
          );

          // Drop the misc_clothes table
          db.execute(
            '''
            DROP TABLE misc_clothes
            ''',
          );

          // Rename the misc_clothes_temp table to misc_clothes
          db.execute(
            '''
            ALTER TABLE misc_clothes_temp
            RENAME TO misc_clothes
            ''',
          );

          // Create temp table for categories
          db.execute(
            '''
            CREATE TABLE categories_temp (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT
            )
            ''',
          );

          // Copy data from categories to categories_temp
          db.execute(
            '''
            INSERT INTO categories_temp (id, name)
            SELECT id, name
            FROM categories
            ''',
          );

          // Drop the categories table
          db.execute(
            '''
            DROP TABLE categories
            ''',
          );

          // Rename the categories_temp table to categories
          db.execute(
            '''
            ALTER TABLE categories_temp
            RENAME TO categories
            ''',
          );
        }
      },
      version: 3,
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
    } else {
      // Get the max value of id from the misc_clothes table
      final List<Map<String, dynamic>> maxId =
          await _database!.rawQuery('SELECT MAX(id) FROM misc_clothes');

      // Set autoincrement to the next available ID
      await _database!.execute(
          "UPDATE SQLITE_SEQUENCE SET SEQ=${maxId[0]['MAX(id)']} WHERE NAME='misc_clothes'");
    }

    // Get the max value of id from the categories table
    final List<Map<String, dynamic>> maxIdCategories =
        await _database!.rawQuery('SELECT MAX(id) FROM categories');

    // Set autoincrement to the next available ID
    await _database!.execute(
        "UPDATE SQLITE_SEQUENCE SET SEQ=${maxIdCategories[0]['MAX(id)']} WHERE NAME='categories'");

    // Get the max value of id from the clothes table
    final List<Map<String, dynamic>> maxIdClothes =
        await _database!.rawQuery('SELECT MAX(id) FROM clothes');

    // Set autoincrement to the next available ID
    await _database!.execute(
        "UPDATE SQLITE_SEQUENCE SET SEQ=${maxIdClothes[0]['MAX(id)']} WHERE NAME='clothes'");

    log.i("Database initialized");
  }

  // ----------------------------------------------------------------
  // Data Controller Functions
  // ----------------------------------------------------------------

  // Function to refresh all list controllers
  void refreshAll() {
    Get.find<ListController>(tag: "basket").refreshData(States.basket);
    Get.find<ListController>(tag: "closet").refreshData(States.closet);
    Get.find<ListController>(tag: "laundry").refreshData(States.laundry);
  }

  // Function to fetch a mapping of category ID to category name
  Future<Map<int, Category>> fetchCategoryMap() async {
    // Get the list of categories
    List<Category> categories = Get.find();
    // Create a map of Category ID to Category
    Map<int, Category> categoryMap = {};
    for (var category in categories) {
      categoryMap[category.id] = category;
    }
    return categoryMap;
  }

  // Function to refresh all category data
  Future<void> refreshCategory() async {
    // Check if the category list is in GetX
    List<Category> categories;

    if (Get.isRegistered<List<Category>>()) {
      categories = Get.find();
    } else {
      categories = [];
      Get.put(categories);
    }
    // Load categories from database
    List<Category> dbCategories = await fetchCategories();
    // Replace the old list with the new list
    categories.assignAll(dbCategories);

    // Check if the category map is in GetX
    Map<int, Category> categoryMap;

    if (Get.isRegistered<Map<int, Category>>()) {
      categoryMap = Get.find();
    } else {
      categoryMap = {};
      Get.put(categoryMap);
    }

    // Load the category map from the database
    Map<int, Category> dbCategoryMap = await fetchCategoryMap();
    // Replace the old map with the new map
    categoryMap.addAll(dbCategoryMap);
  }

  // ----------------------------------------------------------------
  // CRUD for Categories
  // ----------------------------------------------------------------

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

  // Rename a category
  Future<void> renameCategory(int id, String name) async {
    // Prevent the default category from being renamed
    if (id == 1) {
      throw DbException("Default category cannot be renamed");
    }
    // Prevent the category from being renamed to Default
    if (name == "Default") {
      throw DbException("Category name cannot be Default");
    }
    // Prevent the category name from being empty
    if (name.isEmpty) {
      throw DbException("Category name cannot be empty");
    }
    // Prevent the category name from already existing
    if (await checkCategory(name)) {
      throw DbException("Category already exists");
    }

    // Get the database
    Database db = await database;
    // Update the category
    await db.update(
      'categories',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
    await refreshCategory();
  }

  // Delete a category
  Future<void> deleteCategory(int id) async {
    // Make sure its not the default category
    if (id == 1) {
      throw DbException("Default category cannot be deleted");
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
  }

  // ----------------------------------------------------------------
  // CRUD for Clothes
  // ----------------------------------------------------------------

  // Create a clothes entry
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

  // Fetch all clothes
  Future<List<DbEntry>> fetchData() async {
    Database db = await database;
    // Query for all entries
    final List<Map<String, dynamic>> maps = await db.query('clothes');
    return generateList(maps);
  }

  // Fetch data by state
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

  // Update State of an entry
  Future<void> updateState(int id, States state) async {
    Database db = await database;
    int dbState = state.index;
    await db.update(
      'clothes',
      {'state': dbState},
      where: 'id = ?',
      whereArgs: [id],
    );
    refreshAll();
  }

  // Update Category for an entry
  Future<void> updateCategoryForItem(int id, int categoryId) async {
    Database db = await database;
    await db.update(
      'clothes',
      {'category_id': categoryId},
      where: 'id = ?',
      whereArgs: [id],
    );
    await refreshCategory();
  }

  // Update the name of an entry
  Future<void> updateNameOfItem(int id, String value) async {
    // Update the name for the entry
    Database db = await database;

    await db.update(
      'clothes',
      {'name': value},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete an entry
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

  // ----------------------------------------------------------------
  // Misc Functions
  // ----------------------------------------------------------------

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

  // ----------------------------------------------------------------
  // Import-Export Functions
  // ----------------------------------------------------------------

  // Import data
  Future<void> importData(File file) async {
    // Purge the database
    await purgeData();

    // Extract the ZIP file
    await ZipFile.extractToDirectory(
      zipFile: file,
      destinationDir: Directory(join(appDir!.path, "import")),
    );

    // Check if the ZIP file contains a version file
    final versionFile = File(join(appDir!.path, "import", "version.txt"));

    int importVersion = 0;

    if (!versionFile.existsSync()) {
      // Version file not found, import from version 1
      importVersion = 1;
    } else {
      // Read the version file
      final version = await versionFile.readAsString();
      importVersion = int.parse(version);
    }

    // Import data based on the version
    switch (importVersion) {
      case 1:
        await importFromVersion1();
        break;
      case 2:
        await importFromVersion2();
        break;
      case 3:
        await importFromVersion3();
        break;
      default:
        throw DbException("Invalid version number");
    }

    // Declare the directory for the imported data
    final importDir = Directory(join(appDir!.path, "import"));

    // Delete the import directory
    await importDir.delete(recursive: true);
    // Refresh all list controllers
    refreshAll();
    // Refresh the category list
    await refreshCategory();

    // Browse to the home page
    Get.offAllNamed("/home");
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
    // Delete the images directory
    final imagePath = join(appDir!.path, 'images');
    // Check if images directory exists
    if (Directory(imagePath).existsSync()) {
      // Delete the images directory
      await Directory(imagePath).delete(recursive: true);
    }
    // Recreate the images directory
    await Directory(imagePath).create();
    // Delete the database
    await _database!.close();
    // Delete the database file
    await deleteDatabase(join(await getDatabasesPath(), 'data.db'));
    // Recreate the database
    await initDatabase();
    // Refresh all list controllers
    refreshAll();
    // Refresh the category list
    await refreshCategory();
    // Browse to the home page
    Get.offAllNamed("/home");
  }

  // Import data from version 1
  Future<void> importFromVersion1() async {
    // Import data from version 1 of the app
    // Declare the directory for the imported data
    final importDir = Directory(join(appDir!.path, "import"));
    final importDataFile = File(join(importDir.path, "data.json"));

    // Read JSON file and get a list of maps
    final clothesData = await importDataFile.readAsString();
    List jsondata = json.decode(clothesData);

    // Get database
    Database db = await database;

    // Declare the list of DbEntry
    List<DbEntry> dataList = [];

    // Categories do not exist in version 1
    // Set the category_id to 1 for all entries
    for (var data in jsondata) {
      data['categoryId'] = 1;
    }
    // Convert to List of DbEntry
    dataList = jsondata.map((e) => DbEntry.fromJson(e)).toList();

    // Refresh the category list
    await refreshCategory();

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

    // Misc_clothes do not exist in version 1
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

  // Import data from version 2
  Future<void> importFromVersion2() async {
    // Import data from version 2 of the app
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

    // Get the max value of id from the categories table
    final List<Map<String, dynamic>> maxId =
        await db.rawQuery('SELECT MAX(id) FROM categories');

    // Set the sequence to the next available ID
    await db.execute(
        "UPDATE SQLITE_SEQUENCE SET SEQ=${maxId[0]['MAX(id)']} WHERE NAME='categories'");

    // Convert to List of DbEntry
    dataList = jsondata.map((e) => DbEntry.fromJson(e)).toList();

    // Refresh the category list
    await refreshCategory();

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

    // Misc_clothes exists in version 2
    // Read JSON file and get a list of maps
    final miscClothesData = await importMiscClothesFile.readAsString();
    List jsonMiscClothes = json.decode(miscClothesData);
    // Save the items to the database
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

    // Get the max value of id from the misc_clothes table
    final List<Map<String, dynamic>> maxIdMisc =
        await db.rawQuery('SELECT MAX(id) FROM misc_clothes');

    // Set autoincrement to the next available ID
    await db.execute(
        "UPDATE SQLITE_SEQUENCE SET SEQ=${maxIdMisc[0]['MAX(id)']} WHERE NAME='misc_clothes'");
  }

  // Import data from version 3
  Future<void> importFromVersion3() async {
    // Import data from version 3 of the app

    // There was no change in the data structure from version 2 to version 3
    // So the import process is the same as version 2
    await importFromVersion2();
  }
}
