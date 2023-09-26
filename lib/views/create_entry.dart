import 'dart:io';
import 'package:clothes_tracker/models/db_entry.dart';
import 'package:clothes_tracker/models/state.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:clothes_tracker/views/imgpicker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

class DataCaptureScreen extends StatefulWidget {
  // Get a callback when data is saved
  final Function() hasData;
  const DataCaptureScreen({super.key, required this.hasData});

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
  String? imagePath;
  File? imageFile;

  void _receiveImageName(String basePath, String imageName) {
    setState(() {
      imagePath = imageName;
      imageFile = File(join(basePath, 'temp', imageName));
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
                  value: States.wash,
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
                if (imageFile != null) {
                  DbEntry capturedData = DbEntry(
                    id: 0,
                    name: _nameController.text,
                    state: States.values[itemstate],
                    imagePath: imagePath!,
                  );
                  await dbHelper.insertData(capturedData, imageFile!);
                  hasData();
                  Get.back(closeOverlays: true);
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
