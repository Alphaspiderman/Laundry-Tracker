import 'package:clothes_tracker/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateCategory extends StatefulWidget {
  const CreateCategory({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateCategoryState createState() => _CreateCategoryState();
}

class _CreateCategoryState extends State<CreateCategory> {
  final DatabaseHelper dbHelper = Get.find();

  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Category"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Category Name",
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Check if the name is empty
                if (_nameController.text.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Please enter a name',
                    duration: const Duration(seconds: 1),
                  );
                  return;
                }
                // Check if the name already exists
                if (await dbHelper.checkCategory(_nameController.text)) {
                  Get.snackbar(
                    'Error',
                    'Category already exists',
                    duration: const Duration(seconds: 1),
                  );
                  return;
                }
                // Create the category
                await dbHelper.addCategory(_nameController.text);
                Get.back();
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}
