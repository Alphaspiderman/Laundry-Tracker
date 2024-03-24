// Dropdown menu widget for the card
import 'package:clothes_tracker/src/models/category.dart';
import 'package:clothes_tracker/src/models/db_entry.dart';
import 'package:clothes_tracker/src/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Dropdown menu widget for the card having the options to edit name, delete card, change category
class CardDropdown extends StatelessWidget {
  final DbEntry entry;
  final DatabaseHelper dbHelper = Get.find();

  CardDropdown({
    super.key,
    required this.entry,
  });

  void editName() {
    String newName = entry.name;
    // Show a dialog to edit the name
    Get.defaultDialog(
      title: 'Edit Name',
      content: TextField(
        controller: TextEditingController(text: entry.name),
        onChanged: (value) async {
          newName = value;
        },
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Cancel'),
      ),
      confirm: TextButton(
        onPressed: () async {
          // Check for empty String
          if (newName.isEmpty) {
            Get.snackbar(
              'Error',
              'Please enter a name',
              duration: const Duration(seconds: 1),
            );
            return;
          }
          // Check if the name is already the same
          if (newName == entry.name) {
            Get.snackbar(
              'Error',
              'No Change Detected!',
              duration: const Duration(seconds: 1),
            );
            return;
          }
          // Update the name in the database
          await dbHelper.updateNameOfItem(entry.id, newName);
          // Refresh the list
          dbHelper.refreshAll();
          // Close the dialog
          Get.back();
          // Show a notification
          Get.snackbar(
            'Success',
            'Name updated',
            duration: const Duration(seconds: 1),
          );
        },
        child: const Text('Save'),
      ),
    );
  }

  void deleteCard() async {
    // Show a dialog to confirm deletion
    Get.defaultDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      title: 'Delete Card',
      content: const Text('Are you sure you want to delete this Item?'),
      confirm: TextButton(
        onPressed: () async {
          // Delete the card from the database
          await dbHelper.deleteData(entry.id);
          // Refresh the list
          dbHelper.refreshAll();
          // Close the dialog
          Get.back();
          // Show a notification
          Get.snackbar(
            'Success',
            'Item deleted',
            duration: const Duration(seconds: 1),
          );
        },
        child: const Text('Delete'),
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Cancel'),
      ),
      onConfirm: () async {},
    );
  }

  void changeCategory() async {
    // Get the list of categories from the database
    List<Category> categories = await dbHelper.fetchCategories();
    // Variable to store the new category
    int? newCategory;
    // Show a dialog to change the category with a dropdown for selection and a button to confirm
    Get.defaultDialog(
      title: 'Change Category',
      content: DropdownButton(
        value: entry.categoryId,
        onChanged: (value) async {
          newCategory = value;
        },
        items: categories.map((category) {
          return DropdownMenuItem(
            value: category.id,
            child: Text(category.name),
          );
        }).toList(),
      ),
      confirm: TextButton(
        onPressed: () async {
          // Check for null
          if (newCategory == null) {
            Get.snackbar(
              'Error',
              'Please select a category',
              duration: const Duration(seconds: 1),
            );
            return;
          }
          // Check if the category is already the same
          if (newCategory == entry.categoryId) {
            Get.snackbar(
              'Error',
              'Category is already the same',
              duration: const Duration(seconds: 1),
            );
            return;
          }
          // Update the category in the database
          await dbHelper.updateCategoryForItem(entry.id, newCategory!);
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
          child: Text('Delete Card'),
        ),
        const PopupMenuItem(
          value: 3,
          child: Text('Change Category'),
        ),
      ],
      onSelected: (value) {
        if (value == 1) {
          editName();
        } else if (value == 2) {
          deleteCard();
        } else if (value == 3) {
          changeCategory();
        }
      },
    );
  }
}
