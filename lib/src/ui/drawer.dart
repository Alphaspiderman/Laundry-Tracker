import 'dart:io';

import 'package:clothes_tracker/src/utils/db.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  AppDrawerState createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  final Logger log = Get.find();
  final DatabaseHelper dbHelper = Get.find();
  Image drawerHeader = Image.asset(
    'assets/images/drawer_header.jpg',
    cacheHeight: 400,
  );

  void confirmDbPurge() {
    Get.dialog(
      AlertDialog(
        title: const Text("Confirm Action"),
        content: const Text(
          "This will delete all data from the database!!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              log.d("DB Purge cancelled");
            },
            child: const Text("NO"),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await dbHelper.purgeData();
              Get.snackbar("Purge", "DB Purged!");
              log.d("DB Purged");
            },
            child: const Text("YES"),
          ),
        ],
      ),
    );
  }

  void importData() async {
    // Pick a file from the device
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      // User canceled the picker
      Get.snackbar("Import Failed", "No file selected!");
      log.i("Import failed: No file selected");
      return;
    }
    // Get the file path
    String path = result.files.single.path!;
    // Confirm its a ZIP file
    if (!path.endsWith(".zip")) {
      Get.snackbar("Import Failed", "Invalid file type!");
      log.i("Import failed: Invalid file type");
      return;
    } else {
      // Create a popup with a message and yes-no buttons
      Get.dialog(
        AlertDialog(
          title: const Text("Confirm Action"),
          content: const Text(
            "Local data will be removed before import is attempted!! \nIn case of failed import, existing data will not be restored",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                log.d("Import cancelled");
              },
              child: const Text("NO"),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                log.d("Importing data from $path");
                await dbHelper.importData(File(path));
              },
              child: const Text("YES"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: drawerHeader.image,
                fit: BoxFit.cover,
              ),
            ),
            child: const Text(
              'Options',
              style: TextStyle(fontSize: 28),
            ),
          ),
          // Drawer Items
          // Export DB
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export DB'),
            onTap: () {
              Get.back();
              dbHelper.exportData();
            },
          ),
          // Import DB
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import DB'),
            onTap: () {
              Get.back();
              importData();
            },
          ),
          // Divider
          const Divider(),
          // Manage Categories
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Manage Categories'),
            onTap: () {
              Get.back();
              Get.toNamed('/categories');
            },
          ),
          // Divider
          const Divider(),
          // Manage Items
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Manage Items'),
            onTap: () {
              Get.back();
              Get.toNamed('/debug');
            },
          ),
          // Divider
          const Divider(),
          // Purge DB
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Purge DB'),
            onTap: () {
              Get.back();
              confirmDbPurge();
            },
          ),
        ],
      ),
    );
  }
}
