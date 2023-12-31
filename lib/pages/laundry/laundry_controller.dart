import 'package:clothes_tracker/models/db_entry.dart';
import 'package:clothes_tracker/models/state.dart';
import 'package:clothes_tracker/ui/display_card.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:clothes_tracker/utils/list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LaundryController extends GetxController {
  final DatabaseHelper dbHelper = Get.find();
  final ListController listController = Get.find(tag: "laundry");

  // Function to update the list in the controller
  Future<void> refreshData() async {
    // Get the data from the database
    final List<DbEntry> data = await dbHelper.fetchDataByState(States.wash);
    // Update the list in the controller
    listController.items.value = data;
  }

  // Function to remove an item from the list by its ID
  void removeItem(int id) {
    // Loop through the list
    for (int i = 0; i < listController.items.length; i++) {
      // If the ID matches, remove the item
      if (listController.items[i].id == id) {
        listController.items.removeAt(i);
        break;
      }
    }
    // Get and refresh all list controllers
    Get.find<ListController>(tag: "basket").refreshData(States.basket);
    Get.find<ListController>(tag: "closet").refreshData(States.closet);
    Get.find<ListController>(tag: "laundry").refreshData(States.wash);
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
    // Remove from list
    removeItem(id);
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Basket',
      duration: const Duration(seconds: 1),
    );
    // Update the view
    update();
  }

  void moveToCloset(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.closet,
    );
    // Remove from list
    removeItem(id);
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Closet',
      duration: const Duration(seconds: 1),
    );
    // Rebuild the view
    update();
  }

  Widget getBody() {
    if (listController.items.isEmpty) {
      return const Center(
        child: Text(
          "No items in Closet",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    // Return the list view but update as data changes in controller
    return Obx(
      () => ListView.builder(
        itemCount: listController.items.length,
        itemBuilder: (BuildContext context, int index) {
          DbEntry item = listController.items[index];
          return Dismissible(
            key: Key(item.id.toString()),
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.endToStart) {
                moveToBasket(item.id);
              } else {
                moveToCloset(item.id);
              }
              // Remove the item from the list
              removeItem(item.id);
            },
            background: Container(
              color: Colors.green,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(
                    Icons.door_sliding_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              child: const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.shopping_basket,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            child: DisplayCard(
              data: item,
              onFirstButtonPressed: moveToBasket,
              onSecondButtonPressed: moveToCloset,
              onDelete: (int id) async {
                await deleteEntry(id);
              },
            ),
          );
        },
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
