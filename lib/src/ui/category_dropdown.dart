import 'package:clothes_tracker/src/models/category.dart';
import 'package:clothes_tracker/src/models/db_exception.dart';
import 'package:flutter/material.dart';
import 'package:clothes_tracker/src/utils/db.dart';
import 'package:get/get.dart';

class CategoryDropdown extends StatefulWidget {
  // Save the category id
  final Category category;

  // Function to call on callback
  final Function refreshList;

  const CategoryDropdown(
      {super.key, required this.category, required this.refreshList});

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  DatabaseHelper dbHelper = Get.find();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Text('Edit Name'),
        ),
        const PopupMenuItem(
          value: 2,
          child: Text('Delete Category'),
        ),
      ],
      onSelected: (value) {
        if (value == 1) {
          editName();
        } else if (value == 2) {
          deleteCategory();
        }
      },
    );
  }

  void editName() async {
    // Show a dialog to edit the name
    String newName = '';

    Get.defaultDialog(
      title: 'Edit Category Name',
      content: TextField(
        controller: TextEditingController(text: newName),
        onChanged: (value) async {
          newName = value;
          newName = newName.trim();
        },
        decoration: const InputDecoration(
          hintText: 'New Category Name',
        ),
      ),
      confirm: TextButton(
        onPressed: () async {
          // Attempt to update the category
          try {
            await dbHelper.renameCategory(widget.category.id, newName);
          } on DbException catch (e) {
            Get.snackbar(
              'Error',
              e.getMessage(),
              duration: const Duration(seconds: 1),
            );
            return;
          }
          // Refresh the list
          dbHelper.refreshAll();
          // Close the dialog
          Get.back();
          // Show a notification
          Get.snackbar(
            'Success',
            'Category updated',
            duration: const Duration(seconds: 1),
          );
          // Trigger callback
          widget.refreshList();
        },
        child: const Text('Save'),
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Cancel'),
      ),
    );
  }

  void deleteCategory() async {
    // Show a confirmation dialog

    Get.defaultDialog(
      title: 'Delete Category',
      content: const Text('Are you sure you want to delete this category?',
          textAlign: TextAlign.center),
      confirm: TextButton(
        onPressed: () async {
          // Attempt to delete the category
          try {
            await dbHelper.deleteCategory(widget.category.id);
          } on DbException catch (e) {
            Get.snackbar(
              'Error',
              e.getMessage(),
              duration: const Duration(seconds: 1),
            );
            return;
          }
          // Refresh the list
          dbHelper.refreshAll();
          // Close the dialog
          Get.back();
          // Show a notification
          Get.snackbar(
            'Success',
            'Category deleted',
            duration: const Duration(seconds: 1),
          );
          // Trigger callback
          widget.refreshList();
        },
        child: const Text('Delete'),
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Cancel'),
      ),
    );
  }
}
