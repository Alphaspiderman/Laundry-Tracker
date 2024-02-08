import 'package:clothes_tracker/src/models/category.dart';
import 'package:clothes_tracker/src/models/db_entry.dart';
import 'package:clothes_tracker/src/models/state.dart';
import 'package:clothes_tracker/src/ui/display_card.dart';
import 'package:clothes_tracker/src/utils/db.dart';
import 'package:clothes_tracker/src/utils/list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BasketController extends GetxController {
  final DatabaseHelper dbHelper = Get.find();
  final ListController listController = Get.find(tag: "basket");
  final List<Category> categories = Get.find();
  final Logger logger = Get.find();

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
    dbHelper.refreshAll();
  }

  void hasData() {
    Get.snackbar(
      'Success',
      'Data saved successfully',
      duration: const Duration(seconds: 1),
    );
  }

  void moveToCloset(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.closet,
    );
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

  Widget getBody() {
    return Obx(
      () {
        // If the list is empty, show a message
        if (listController.items.isEmpty) {
          return const Center(
            child: Text(
              "Basket is Empty",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        // Return a list of expansion tiles for each categories with cards inside
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, idx) {
            Category category = categories[idx];
            return ExpansionTile(
              initiallyExpanded: true,
              title: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listController.items.length,
                  itemBuilder: (context, index) {
                    DbEntry item = listController.items[index];
                    if (item.categoryId == category.id) {
                      return Dismissible(
                        key: Key(item.id.toString()),
                        onDismissed: (DismissDirection direction) {
                          if (direction == DismissDirection.endToStart) {
                            moveToCloset(item.id);
                          } else {
                            moveToLaundry(item.id);
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
                                Icons.local_laundry_service,
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
                                Icons.door_sliding_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        child: DisplayCard(data: item),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ],
            );
          },
        );
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
