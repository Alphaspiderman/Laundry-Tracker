import 'package:clothes_tracker/utils/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () {
              Get.snackbar("Test", "Hello!");
            },
            child: const Text('Trigger Snack'),
          )
        ],
      ),
    );

    return BasePage(title: "Home Page", body: body);
  }
}
