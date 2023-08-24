import 'package:flutter/material.dart';
import 'package:clothes_tracker/utils/base.dart';

class BasketPage extends StatelessWidget {
  const BasketPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BasePage(
      title: "Basket",
      body: Center(
        child: Text('Basket'),
      ),
    );
  }
}
