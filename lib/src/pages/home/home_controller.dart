import 'package:clothes_tracker/src/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final DatabaseHelper dbHelper = Get.find();

  // Function to get the body
  Future<Column> getBody() async {
    Map<String, int> data = await dbHelper.getStats();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Show statistics of the app
        Column(
          children: [
            Text(
              'Total Items: ${data['Total']}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'In Closet: ${data['Closet']}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'In Basket: ${data['Basket']}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'In Wash: ${data['Wash']}',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }
}
