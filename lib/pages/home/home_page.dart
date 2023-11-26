import 'dart:io';
import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:clothes_tracker/views/create_entry.dart';
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

  void _hasData() {
    Get.snackbar(
      'Success',
      'Data saved successfully',
      duration: const Duration(seconds: 2),
    );
    setState(() {});
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
        AlertDialog(
          title: const Text("Confirm Action"),
          content: const Text(
            "Local data will be removed before import is attempted!! \nIn case of failed import, existing data will not be restored",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("NO"),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                await dbHelper.importData(File(path));
              },
              child: const Text("YES"),
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
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool isScrolled) {
          return [
            const CustomAppBar(
              title: 'Home',
            ),
          ];
        },
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Show statistics of the app
              FutureBuilder(
                future: dbHelper.getStats(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Text(
                          "Total Items: ${snapshot.data!["Total"]}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          "In Closet: ${snapshot.data!["Closet"]}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          "In Basket: ${snapshot.data!["Basket"]}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          "In Wash: ${snapshot.data!["Wash"]}",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              Column(
                children: [
                  // Add a button to refresh
                  OutlinedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Refresh'),
                  ),
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
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () async {
          Get.to(() => DataCaptureScreen(hasData: _hasData));
        },
      ),
      bottomNavigationBar: const NavBar(itemIndex: 0),
    );
  }
}
