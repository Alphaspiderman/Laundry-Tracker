import 'dart:io';

import 'package:clothes_tracker/src/models/category.dart';
import 'package:clothes_tracker/src/models/db_entry.dart';
import 'package:clothes_tracker/src/models/state.dart';
import 'package:clothes_tracker/src/utils/db.dart';
import 'package:clothes_tracker/src/views/imgpicker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:image_cropper/image_cropper.dart';

class DataCaptureScreen extends StatefulWidget {
  // Get a callback when data is saved
  final Function() hasData;

  const DataCaptureScreen({
    super.key,
    required this.hasData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DataCaptureScreenState createState() => _DataCaptureScreenState();
}

class _DataCaptureScreenState extends State<DataCaptureScreen> {
  void hasData() {
    widget.hasData();
  }

  final DatabaseHelper dbHelper = Get.find();
  final TextEditingController _nameController = TextEditingController();
  int itemstate = 0;
  File? origianlImage;
  String? imagePath;
  File? imageFile;
  int? categoryId;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    dbHelper.fetchCategories().then((value) {
      setState(() {
        categories = value;
      });
    });
  }

  void _receiveImageName(String basePath, String imageName) {
    setState(() {
      imagePath = imageName;
      imageFile = File(join(basePath, 'temp', imageName));
      origianlImage = File(join(basePath, 'temp', imageName));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            ImagePickerWidget(onDataReceived: _receiveImageName),
            const SizedBox(height: 16.0),
            // Display the image if it exists but limit the size
            if (imagePath != null)
              SizedBox(
                height: 200,
                child: Image.file(imageFile!),
              ),
            const SizedBox(height: 16.0),
            if (imagePath != null)
              ElevatedButton(
                onPressed: () async {
                  final croppedFile = await ImageCropper().cropImage(
                    sourcePath: origianlImage!.path,
                    compressQuality: 90,
                    compressFormat: ImageCompressFormat.jpg,
                    uiSettings: [
                      AndroidUiSettings(
                          toolbarTitle: 'Image Cropper',
                          toolbarColor:
                              Get.isDarkMode ? Colors.black : Colors.white,
                          toolbarWidgetColor:
                              Get.isDarkMode ? Colors.white : Colors.black,
                          statusBarColor:
                              Get.isDarkMode ? Colors.black : Colors.white,
                          backgroundColor: Colors.black.withOpacity(0.5),
                          initAspectRatio: CropAspectRatioPreset.square,
                          lockAspectRatio: false),
                    ],
                  );
                  if (croppedFile != null) {
                    setState(
                      () {
                        imageFile = File(croppedFile.path);
                      },
                    );
                  }
                },
                child: const Text('Crop Image'),
              ),
            const SizedBox(height: 16.0),
            // Dropdown to select the category
            DropdownButtonFormField(
              value: categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  categoryId = value as int;
                });
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField(
              value: States.closet,
              decoration: const InputDecoration(labelText: 'State'),
              items: const [
                DropdownMenuItem(
                  value: States.closet,
                  child: Text('Closet'),
                ),
                DropdownMenuItem(
                  value: States.basket,
                  child: Text('Basket'),
                ),
                DropdownMenuItem(
                  value: States.laundry,
                  child: Text('Laundry'),
                ),
              ],
              onChanged: (value) {
                itemstate = value!.index;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (imageFile != null &&
                    categoryId != null &&
                    _nameController.text.isNotEmpty) {
                  DbEntry capturedData = DbEntry(
                    id: 0,
                    name: _nameController.text,
                    state: States.values[itemstate],
                    imagePath: imagePath!,
                    categoryId: categoryId!,
                  );
                  await dbHelper.insertData(capturedData, imageFile!);
                  dbHelper.refreshAll();
                  hasData();
                  Get.back(closeOverlays: true);
                } else if (imageFile == null) {
                  Get.snackbar(
                    'Error',
                    'Please select an image',
                    duration: const Duration(seconds: 1),
                  );
                } else if (categoryId == null) {
                  Get.snackbar(
                    'Error',
                    'Please select a category',
                    duration: const Duration(seconds: 1),
                  );
                } else if (_nameController.text.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Please enter a name',
                    duration: const Duration(seconds: 1),
                  );
                }
              },
              child: const Text('Save Data'),
            ),
          ],
        ),
      ),
    );
  }
}
