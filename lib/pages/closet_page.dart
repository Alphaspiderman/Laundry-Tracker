import 'package:flutter/material.dart';
import 'package:clothes_tracker/pages/base.dart';
import 'package:get/get.dart';

class ClosetPage extends StatelessWidget {
  const ClosetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Page 1",
      body: Center(
        child: OutlinedButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Goto Home'),
        ),
      ),
    );
  }
}
