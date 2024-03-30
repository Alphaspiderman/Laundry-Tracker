import 'package:clothes_tracker/src/models/category.dart';
import 'package:clothes_tracker/src/ui/category_dropdown.dart';

import 'package:clothes_tracker/src/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageCategoryPage extends StatefulWidget {
  const ManageCategoryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ManageCategoryPageState createState() => _ManageCategoryPageState();
}

class _ManageCategoryPageState extends State<ManageCategoryPage> {
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

  void refreshList() {
    dbHelper.fetchCategories().then((value) {
      setState(() {
        categories = value;
      });
    });
  }

  int? categoryId;
  String categoryName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Categories"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    trailing: CategoryDropdown(
                        category: category, refreshList: refreshList),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Add Category',
                  content: TextField(
                    onChanged: (value) {
                      categoryName = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Category Name',
                    ),
                  ),
                  confirm: TextButton(
                    onPressed: () {
                      if (categoryName.isNotEmpty) {
                        dbHelper.addCategory(categoryName).then((value) {
                          refreshList();
                        });
                      }
                      Get.back();
                    },
                    child: const Text('Add'),
                  ),
                  cancel: TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Cancel'),
                  ),
                );
              },
              child: const Text('Add Category'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
