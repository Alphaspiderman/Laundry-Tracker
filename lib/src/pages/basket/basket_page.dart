import 'package:clothes_tracker/src/navigation/navgation_bar.dart';
import 'package:clothes_tracker/src/pages/basket/basket_controller.dart';
import 'package:clothes_tracker/src/ui/app_bar.dart';
import 'package:clothes_tracker/src/ui/drawer.dart';
import 'package:clothes_tracker/src/views/create_entry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BasketPage extends GetWidget<BasketController> {
  const BasketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool isScrolled) {
          return [
            const CustomAppBar(
              title: 'Basket',
            ),
          ];
        },
        body: controller.getBody(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () async {
          Get.to(() => DataCaptureScreen(hasData: controller.hasData));
        },
      ),
      bottomNavigationBar: const NavBar(itemIndex: 3),
    );
  }
}
