import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/pages/basket/basket_controller.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:clothes_tracker/views/create_entry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BasketPage extends StatefulWidget {
  const BasketPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  final BasketController basketController = BasketController();

  @override
  void initState() {
    super.initState();
    basketController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool isScrolled) {
          return [
            const CustomAppBar(
              title: 'Basket',
            ),
          ];
        },
        body: basketController.getBody(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () async {
          Get.to(() => DataCaptureScreen(hasData: basketController.hasData));
        },
      ),
      bottomNavigationBar: const NavBar(itemIndex: 3),
    );
  }
}
