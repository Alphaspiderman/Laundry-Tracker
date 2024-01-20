import 'dart:io';

import 'package:clothes_tracker/models/db_entry.dart';
import 'package:clothes_tracker/models/state.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DebugCard extends StatelessWidget {
  final DbEntry data;
  final Function(int) onDelete;
  final DatabaseHelper dbHelper = Get.find();

  DebugCard({
    super.key,
    required this.data,
    required this.onDelete,
  });

  // Mapping of the state to the text to be displayed
  static const Map<States, String> stateText = {
    States.closet: 'Closet',
    States.basket: 'Basket',
    States.laundry: 'Laundry',
  };

  void moveToCloset(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.closet,
    );
    // Remove from list
    dbHelper.refreshAll();
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Closet',
      duration: const Duration(seconds: 1),
    );
  }

  void moveToBasket(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.basket,
    );
    // Remove from list
    dbHelper.refreshAll();
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Basket',
      duration: const Duration(seconds: 1),
    );
    // Update the view
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

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = generateButtons();
    // Make a card with the data and buttons but limit the height to 300 pixels and fully expand the width of the screen
    return SizedBox(
      height: 350,
      child: Card(
        child: Column(
          children: [
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              title: Text(data.name),
              titleTextStyle: const TextStyle(
                fontSize: 26,
              ),
              subtitle: Text("Currently in ${stateText[data.state]}"),
              subtitleTextStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.dialog(
                  Dialog(
                    child: Image.file(
                      File(data.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
              child: SizedBox(
                child: Image.file(
                  File(data.imagePath),
                  fit: BoxFit.fitWidth,
                  cacheHeight: 200,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buttons,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> generateButtons() {
    // Create and add buttons to the list based on the state of the data
    List<Widget> buttons = [];
    // Change text options based on data state
    switch (data.state) {
      case States.closet:
        buttons.add(
          OutlinedButton(
            onPressed: () {
              moveToBasket(data.id);
            },
            child: const Text('Move to Basket'),
          ),
        );
        buttons.add(
          OutlinedButton(
            onPressed: () {
              moveToLaundry(data.id);
            },
            child: const Text('Move to Laundry'),
          ),
        );
        break;
      case States.basket:
        buttons.add(
          OutlinedButton(
            onPressed: () {
              moveToCloset(data.id);
            },
            child: const Text('Move to Closet'),
          ),
        );
        buttons.add(
          OutlinedButton(
            onPressed: () {
              moveToLaundry(data.id);
            },
            child: const Text('Move to Laundry'),
          ),
        );
        break;
      case States.laundry:
        buttons.add(
          OutlinedButton(
            onPressed: () {
              moveToCloset(data.id);
            },
            child: const Text('Move to Closet'),
          ),
        );
        buttons.add(
          OutlinedButton(
            onPressed: () {
              moveToBasket(data.id);
            },
            child: const Text('Move to Basket'),
          ),
        );
        break;
    }

    // Add the delete icon button in the middle
    buttons.insert(
      1,
      IconButton(
        onPressed: () async {
          await onDelete(data.id);
        },
        icon: const Icon(Icons.delete_outline_rounded),
        color: Colors.red,
      ),
    );
    return buttons;
  }
}
