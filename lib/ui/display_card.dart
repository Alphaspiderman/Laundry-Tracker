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
    Key? key,
    required this.data,
    required this.onFirstButtonPressed,
    required this.onSecondButtonPressed,
    required this.onDelete,
    this.onThirdButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if onThirdButtonPressed is null
    bool check = onThirdButtonPressed == null;
    List<Widget> buttons = check ? generateButtons() : generateButtonsDebug();
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(data.name),
            titleTextStyle: const TextStyle(
              fontSize: 26,
            ),
            subtitle: Text("Currently in ${data.state.name.capitalizeFirst}"),
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
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.file(
                File(data.imagePath),
                height: 400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buttons,
            ),
          ),
        ],
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
        onPressed: () => onSecondButtonPressed(data.id),
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
