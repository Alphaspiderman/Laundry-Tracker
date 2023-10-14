import 'dart:io';

import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DatabaseHelper dbHelper;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
    dbHelper = Get.find();
  }

  void importData() async {
    // Pick a file from the device
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      // User canceled the picker
      Get.snackbar("Import Failed", "No file selected!");
      return;
    }
    // Get the file path
    String path = result.files.single.path!;
    // Confirm its a ZIP file
    if (!path.endsWith(".zip")) {
      Get.snackbar("Import Failed", "Invalid file type!");
      return;
    } else {
      // Create a popup with a message and yes-no buttons
      Get.dialog(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 30,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Warning",
                        style: TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Local data will be removed before import is attempted!! \nIncase of failed import, exisiting data will not be restored",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text(
                                'NO',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await dbHelper.importData(File(path));
                              },
                              child: const Text(
                                'YES',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Function to export all data of the app as ZIP
  void exportData() async {
    await dbHelper.exportData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Home",
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add a button to purge the DB
            OutlinedButton(
              onPressed: () async {
                await dbHelper.purgeData();
                Get.snackbar("Purge", "DB Purged!");
              },
              child: const Text('Purge DB'),
            ),
            // Add a button to toggle debug page
            OutlinedButton(
              onPressed: () {
                Get.toNamed("/debug");
              },
              child: const Text('Debug Page'),
            ),
            // Add a button to import data
            OutlinedButton(
              onPressed: () {
                importData();
              },
              child: const Text('Import Data'),
            ),
            // Add a button to export data
            OutlinedButton(
              onPressed: () {
                exportData();
              },
              child: const Text('Export Data'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(itemIndex: 0),
    );
  }
}
