import 'package:flutter/material.dart';
import 'package:clothes_tracker/utils/base.dart';

class ClosetPage extends StatelessWidget {
  const ClosetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BasePage(
      title: "Closet",
      body: Center(
        child: Text('Closet'),
      ),
    );
  }
}
