import 'package:clothes_tracker/src/models/category.dart';
import 'package:clothes_tracker/src/models/db_entry.dart';
import 'package:clothes_tracker/src/models/state.dart';
import 'package:clothes_tracker/src/ui/display_card.dart';
import 'package:clothes_tracker/src/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppPageController extends GetxController {
  final DatabaseHelper dbHelper = Get.find();
  Map<int, Category> categoryMap = Get.find();

  Future<Widget> buildPage(States state) async {
    List<DbEntry> data = await getData(state);

    if (data.isEmpty) {
      return const Center(
        child: Text(
          "Laundry is Empty",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Make an empty list of categories
    Map<Category, List<DbEntry>> localData = {};

    // Only add categories that have items in the list
    for (DbEntry entry in data) {
      Category category = categoryMap[entry.categoryId]!;
      if (localData.containsKey(category)) {
        if (localData[category] != null) {
          localData[category]!.add(entry);
        } else {
          localData[category] = [entry];
        }
      } else {
        localData[category] = [entry];
      }
    }

    // Sort the categories by their id
    List<Category> sortedCategories = localData.keys.toList();
    sortedCategories.sort((a, b) => a.id.compareTo(b.id));

    // Map a list of cards to each category
    Map<Category, List<Widget>> categoryCards = {};
    for (Category category in sortedCategories) {
      List<Widget> cards = [];
      for (DbEntry entry in localData[category]!) {
        cards.add(
          Dismissible(
            key: Key(entry.id.toString()),
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.endToStart) {
                moveToBasket(entry.id);
              } else {
                moveToCloset(entry.id);
              }
              update();
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
            child: DisplayCard(data: entry),
          ),
        );
      }
      categoryCards[category] = cards;
    }

    // Return a ListView of the categories
    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, idx) {
        Category category = sortedCategories[idx];
        return ExpansionTile(
          initiallyExpanded: false,
          title: Text(
            category.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: categoryCards[category]!,
        );
      },
    );
  }

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
