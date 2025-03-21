import 'package:clothes_tracker/src/models/category.dart';
import 'package:clothes_tracker/src/models/db_entry.dart';
import 'package:clothes_tracker/src/models/state.dart';
import 'package:clothes_tracker/src/utils/db.dart';
import 'package:clothes_tracker/src/utils/snackbar_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppPageController extends GetxController {
  final DatabaseHelper dbHelper = Get.find();
  Map<int, Category> categoryMap = Get.find();

  Future<List<DbEntry>> getData(States state) async {
    return await dbHelper.fetchDataByState(state);
  }

  void hasData() {
    SnackbarManager().showSnackbar(
      const GetSnackBar(
        title: 'Success',
        message: 'Data saved successfully',
        duration: Duration(seconds: 2),
      ),
    );
    // Rebuild
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
    SnackbarManager().showSnackbar(
      const GetSnackBar(
        title: 'Success',
        message: 'Item moved to Basket',
        duration: Duration(seconds: 2),
      ),
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
    SnackbarManager().showSnackbar(
      const GetSnackBar(
        title: 'Success',
        message: 'Item moved to Closet',
        duration: Duration(seconds: 2),
      ),
    );
  }

  void moveToLaundry(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.laundry,
    );
    // Rebuild
    update();
    // Show a notification
    SnackbarManager().showSnackbar(
      const GetSnackBar(
        title: 'Success',
        message: 'Item moved to Laundry',
        duration: Duration(seconds: 2),
      ),
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
              SnackbarManager().showSnackbar(
                const GetSnackBar(
                  title: 'Deletion',
                  message: 'Entry Deleted!',
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("YES"),
          ),
        ],
      ),
    );
  }
}
