import 'package:clothes_tracker/src/models/category.dart';
import 'package:clothes_tracker/src/models/db_entry.dart';
import 'package:clothes_tracker/src/models/state.dart';
import 'package:clothes_tracker/src/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppPageController extends GetxController {
  final DatabaseHelper dbHelper = Get.find();
  Map<int, Category> categoryMap = Get.find();

  Future<List<DbEntry>> getData(States state) async {
    return await dbHelper.fetchDataByState(state);
  }

  void hasData() {
    Get.snackbar(
      'Success',
      'Data saved successfully',
      duration: const Duration(seconds: 1),
    );
    update();
  }

  void moveToBasket(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.basket,
    );
    // Rebuild
    update();
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Basket',
      duration: const Duration(seconds: 1),
    );
  }

  void moveToCloset(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.closet,
    );
    // Rebuild
    update();
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Closet',
      duration: const Duration(seconds: 1),
    );
  }

  void moveToLaundry(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.laundry,
    );
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Laundry',
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> deleteEntry(int id) async {
    Get.dialog(
      AlertDialog(
        title: const Text("Confirm Action"),
        content: const Text(
          "Please confirm if you want to remove the following entry",
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
              await dbHelper.deleteData(id);
              dbHelper.refreshAll();
              Get.snackbar(
                "Deletion",
                "Entry Deleted!",
              );
            },
            child: const Text("YES"),
          ),
        ],
      ),
    );
  }
}
