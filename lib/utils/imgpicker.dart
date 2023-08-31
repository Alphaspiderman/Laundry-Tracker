import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerWidget extends StatelessWidget {
  final Function(String) onDataReceived;

  const ImagePickerWidget({super.key, required this.onDataReceived});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        XFile? imageFile = await pickImage(context);
        if (imageFile != null) {
          // Save the image with a random name
          final appDir = await getApplicationDocumentsDirectory();
          print(appDir.path.toString());
          final imageName = '${DateTime.now()}.png';
          final finalImagePath = join(appDir.path, 'images', imageName);
          // Create folders if do not exist
          await Directory(join(appDir.path, 'images')).create(recursive: true);
          // Move file
          await imageFile.saveTo(finalImagePath);
          print(finalImagePath.toString());
          onDataReceived(finalImagePath);
        }
      },
      child: const Text('Pick Image'),
    );
  }

  Future<XFile?> pickImage(BuildContext context) async {
    final picker = ImagePicker();

    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

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
