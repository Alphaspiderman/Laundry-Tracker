import 'package:clothes_tracker/models/db_entry.dart';
import 'package:clothes_tracker/models/state.dart';
import 'package:clothes_tracker/ui/display_card.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:clothes_tracker/utils/list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DebugController extends GetxController {
  final DatabaseHelper dbHelper = Get.find();

  void refreshLists(int id) {
    // Get and refresh all list controllers
    Get.find<ListController>(tag: "basket").refreshData(States.basket);
    Get.find<ListController>(tag: "closet").refreshData(States.closet);
    Get.find<ListController>(tag: "laundry").refreshData(States.laundry);
  }

  void hasData() {
    Get.snackbar(
      'Success',
      'Data saved successfully',
      duration: const Duration(seconds: 1),
    );
    update();
  }

  void moveToCloset(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.closet,
    );
    // Remove from list
    refreshLists(id);
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Closet',
      duration: const Duration(seconds: 1),
    );
    // Update the view
    update();
  }

  void moveToBasket(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.basket,
    );
    // Remove from list
    refreshLists(id);
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Basket',
      duration: const Duration(seconds: 1),
    );
    // Update the view
    update();
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
    // Rebuild the view
    update();
  }

  FutureBuilder getBody() {
    return FutureBuilder(
      future: dbHelper.fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            heightFactor: 10,
            widthFactor: 10,
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Display details about data
          List<DbEntry> dataList = snapshot.data as List<DbEntry>;
          // Display the items in list as cards
          return ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              // return a display card
              return DisplayCard(
                data: dataList[index],
                onFirstButtonPressed: moveToCloset,
                onSecondButtonPressed: moveToBasket,
                onDelete: (int id) async {
                  await deleteEntry(id);
                },
                onThirdButtonPressed: moveToLaundry,
              );
            },
          );
        }
      },
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
              Get.snackbar(
                "Deletion",
                "Entry Deleted!",
              );
              update();
            },
            child: const Text("YES"),
          ),
        ],
      ),
    );
  }
}
