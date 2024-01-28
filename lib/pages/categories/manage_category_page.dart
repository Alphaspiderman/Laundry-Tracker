import 'package:clothes_tracker/models/category.dart';
import 'package:clothes_tracker/pages/categories/categories_controller.dart';
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
  final CategoriesController categoryController = CategoriesController();

  final TextEditingController _nameController = TextEditingController();

  List<Category> categories = [];
  DatabaseHelper dbHelper = Get.find();

  @override
  void initState() {
    super.initState();
    dbHelper.fetchCategories().then((value) {
      setState(() {
        categories = value;
      });
    });
  }

  int? categoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Categories"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Category Creation",
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
                    categoryController
                        .handleCategoryCreate(_nameController.text);
                  },
                  child: const Text("Create"),
                ),
              ],
            ),
            // Allow deletion of a category selected from a dropdown
            // Dropdown to select the category
            Column(
              children: [
                DropdownButtonFormField(
                  value: categoryId,
                  hint: const Text("Select a category to delete"),
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
                // Show a button to delete the category
                ElevatedButton(
                  onPressed: () async {
                    // Check if the name is empty
                    if (categoryId == null) {
                      Get.snackbar(
                        'Error',
                        'Please select a category',
                        duration: const Duration(seconds: 1),
                      );
                      return;
                    }
                    categoryController.handleCategoryDelete(categoryId!);
                  },
                  child: const Text("Delete"),
                ),
              ],
            ),

            // Show a button to cancel the action
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("Cancel"),
            ),
            const SizedBox(),
          ],
        ),
      ),
    );
  }
}
