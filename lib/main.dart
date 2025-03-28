import 'dart:io';

import 'package:clothes_tracker/src/utils/app_page_controller.dart';
import 'package:clothes_tracker/src/utils/db.dart';
import 'package:clothes_tracker/src/utils/list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:clothes_tracker/src/app.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initalise Logger
  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: stdout.supportsAnsiEscapes,
      printEmojis: false,
      printTime: true,
    ),
  );
  // Put Logger in GetX
  Get.put(logger);

  // Manage Folders
  final appDir = await getApplicationDocumentsDirectory();

  // Check if images folder exists
  final imagesDir = Directory(join(appDir.path, 'images'));
  if (!imagesDir.existsSync()) {
    await imagesDir
        .create(recursive: true)
        .then((value) => logger.d('Created images folder'));
  }

  // Delete the old import/export folders
  final oldImportDir = Directory(join(appDir.path, 'import'));
  final oldExportDir = Directory(join(appDir.path, 'export'));

  if (oldImportDir.existsSync()) {
    await oldImportDir
        .delete(recursive: true)
        .then((value) => logger.d('Deleted old import folder'));
  }
  if (oldExportDir.existsSync()) {
    await oldExportDir
        .delete(recursive: true)
        .then((value) => logger.d('Deleted old export folder'));
  }

  DatabaseHelper db = DatabaseHelper();
  await db.initClass();

  Get.put(db);

  // Initialise the lists
  Get.put(ListController(), tag: "closet");
  Get.put(ListController(), tag: "basket");
  Get.put(ListController(), tag: "laundry");

  // Categories list from database
  Get.put(await db.fetchCategories(), permanent: true);
  Get.put(await db.fetchCategoryMap(), permanent: true);

  // Refresh all lists using the database
  db.refreshAll();

  // Initialise the controller
  Get.put(AppPageController());

  runApp(const LaundryApp());
}
