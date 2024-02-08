import 'dart:io';

import 'package:clothes_tracker/src/models/db_entry.dart';
import 'package:clothes_tracker/src/models/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clothes_tracker/src/ui/card_dropdown.dart';

class DisplayCard extends StatelessWidget {
  final DbEntry data;

  const DisplayCard({
    super.key,
    required this.data,
  });

  // Mapping of the state to the text to be displayed
  static const Map<States, String> stateText = {
    States.closet: 'Closet',
    States.basket: 'Basket',
    States.laundry: 'Laundry',
  };

  @override
  Widget build(BuildContext context) {
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
              trailing: CardDropdown(entry: data),
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
                  cacheHeight: 250,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
