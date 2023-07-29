import 'package:clothes_tracker/pages/base.dart';
import 'package:clothes_tracker/pages/closet_page.dart';
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
          ),
          OutlinedButton(
            onPressed: () {
              Get.to(() => const ClosetPage());
            },
            child: const Text('Goto Page 1'),
          ),
        ],
      ),
    );

    return BasePage(title: "Home Page", body: body);
  }
}
