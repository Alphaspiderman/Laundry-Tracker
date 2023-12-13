import 'dart:io';

import 'package:clothes_tracker/pages/basket/basket_page.dart';
import 'package:clothes_tracker/pages/closet/closet_page.dart';
import 'package:clothes_tracker/pages/debug/debug.dart';
import 'package:clothes_tracker/pages/home/home_page.dart';
import 'package:clothes_tracker/pages/laundry/laundry_page.dart';
import 'package:clothes_tracker/themes/dark.dart';
import 'package:clothes_tracker/themes/light.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:clothes_tracker/utils/list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'models/state.dart';

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

  runApp(const MyApp());

  ListController closetList = Get.put(ListController(), tag: "closet");
  ListController basketList = Get.put(ListController(), tag: "basket");
  ListController washList = Get.put(ListController(), tag: "laundry");

  // Fetch data for each list
  closetList.refreshData(States.closet);
  basketList.refreshData(States.basket);
  washList.refreshData(States.wash);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Laundry Tracker',
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system,
      // home: const HomePage(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/closet', page: () => const ClosetPage()),
        GetPage(name: '/basket', page: () => const BasketPage()),
        GetPage(name: '/laundry', page: () => const LaundryPage()),
        GetPage(name: '/debug', page: () => const DebugPage()),
      ],
    );
  }
}
