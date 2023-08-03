import 'package:flutter/material.dart';
import 'package:clothes_tracker/utils/base.dart';

class LaundryPage extends StatelessWidget {
  const LaundryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BasePage(
      title: "Laundry",
      body: Center(
        child: Text('Laundry'),
      ),
    );
  }
}
