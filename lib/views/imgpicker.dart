import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerWidget extends StatelessWidget {
  final Function(String, String) onDataReceived;

  const ImagePickerWidget({super.key, required this.onDataReceived});

  String getSafe() {
    var now = DateTime.now();
    String safeString = now.microsecond.toString() +
        now.second.toString() +
        now.minute.toString();
    return safeString;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
            XFile? imageFile = await pickImage(context, ImageSource.gallery);
            await processFile(imageFile);
          },
          child: const Text('Pick Image'),
        ),
        ElevatedButton(
          onPressed: () async {
            XFile? imageFile = await pickImage(context, ImageSource.camera);
            await processFile(imageFile);
          },
          child: const Text('Take an Image'),
        ),
      ],
    );
  }

  Future<void> processFile(XFile? imageFile) async {
    if (imageFile != null) {
      // Get the application directory
      final appDir = await getApplicationDocumentsDirectory();

      // Create a unique image name
      String safeString = getSafe();
      String imageName = '${imageFile.path.hashCode}-$safeString.png';

      // Create folders if do not exist
      await Directory(join(appDir.path, 'temp')).create(recursive: true);
      await Directory(join(appDir.path, 'images')).create(recursive: true);

      // Create the path for checking
      String finalImagePath = join(appDir.path, 'images', imageName);

      // Make sure the file does not exist in final location
      var file = File(finalImagePath);
      // If the file exists, create a new name
      if (await file.exists()) {
        String safeString = DateTime.now().microsecond.toString() +
            DateTime.now().second.toString() +
            DateTime.now().minute.toString();
        imageName = '${imageFile.path.hashCode}-$safeString.png';
      }

      // Create the final paths for the temp and final locations
      String tempImagePath = join(appDir.path, 'temp', imageName);

      // Move file to temp location
      await imageFile.saveTo(tempImagePath);
      onDataReceived(appDir.path, imageName);
    }
  }

  Future<XFile?> pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();

    try {
      final XFile? pickedFile =
          await picker.pickImage(source: source, imageQuality: 100);

      if (pickedFile != null) {
        return pickedFile;
      } else {
        return null;
      }
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }
}
