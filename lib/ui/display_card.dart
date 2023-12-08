import 'dart:io';

import 'package:clothes_tracker/models/db_entry.dart';
import 'package:clothes_tracker/models/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DisplayCard extends StatelessWidget {
  final DbEntry data;
  final Function(int) onFirstButtonPressed;
  final Function(int) onSecondButtonPressed;
  final Function(int)? onThirdButtonPressed;
  final Function(int) onDelete;

  const DisplayCard({
    super.key,
    required this.data,
    required this.onFirstButtonPressed,
    required this.onSecondButtonPressed,
    required this.onDelete,
    this.onThirdButtonPressed,
  });

  // Mapping of the state to the text to be displayed
  static const Map<States, String> stateText = {
    States.closet: 'Closet',
    States.basket: 'Basket',
    States.wash: 'Laundry',
  };

  @override
  Widget build(BuildContext context) {
    bool check = onThirdButtonPressed == null;
    List<Widget> buttons = check ? generateButtons() : generateButtonsDebug();
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

  List<Widget> generateButtonsDebug() {
    // Change text options based on data state
    List<Widget> buttons = [];
    // Add the first button
    buttons.add(
      OutlinedButton(
        onPressed: () => onFirstButtonPressed(data.id),
        child: const Text('Closet'),
      ),
    );
    // Add the second button
    buttons.add(
      OutlinedButton(
        onPressed: () => onSecondButtonPressed(data.id),
        child: const Text('Basket'),
      ),
    );
    // Add the third Button
    buttons.add(
      OutlinedButton(
        onPressed: () => onThirdButtonPressed!(data.id),
        child: const Text('Laundry'),
      ),
    );
    buttons.add(IconButton(
      onPressed: () async {
        await onDelete(data.id);
      },
      icon: const Icon(Icons.delete_outline_rounded),
      color: Colors.red,
    ));
    return buttons;
  }

  List<Widget> generateButtons() {
    // Change text options based on data state
    Text firstText;
    Text secondText;
    switch (data.state) {
      case States.closet:
        firstText = const Text('Move to Basket');
        secondText = const Text('Send to Laundry');
        break;
      case States.basket:
        firstText = const Text('Move to Closet');
        secondText = const Text('Send to Laundry');
        break;
      case States.wash:
        firstText = const Text('Move to Basket');
        secondText = const Text('Move to Closet');
        break;
      default:
        firstText = const Text('Error');
        secondText = const Text('Error');
    }

    List<Widget> buttons = [];
    // Add the first button
    buttons.add(
      OutlinedButton(
        onPressed: () => onFirstButtonPressed(data.id),
        child: firstText,
      ),
    );
    buttons.add(IconButton(
      onPressed: () async {
        await onDelete(data.id);
      },
      icon: const Icon(Icons.delete_outline_rounded),
      color: Colors.red,
    ));
    // Add the second button
    buttons.add(
      OutlinedButton(
        onPressed: () => onSecondButtonPressed(data.id),
        child: secondText,
      ),
    );
    return buttons;
  }
}
