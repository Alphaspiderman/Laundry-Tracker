import 'package:clothes_tracker/pages/basket_page.dart';
import 'package:clothes_tracker/pages/closet_page.dart';
import 'package:clothes_tracker/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomNavController extends GetxController {
  var idx = 0.obs;

  void changeIndex(int index) {
    idx.value = index;
  }
}

class CustomBottomNavBar extends StatelessWidget {
  CustomBottomNavBar({Key? key}) : super(key: key);
  final CustomBottomNavController navController =
      Get.put(CustomBottomNavController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navController.idx.value,
          children: const [HomePage(), BasketPage(), ClosetPage()],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          selectedItemColor: Get.isDarkMode ? Colors.white : Colors.black,
          unselectedItemColor: Get.isDarkMode ? Colors.white38 : Colors.black38,
          onTap: (index) {
            navController.changeIndex(index);
          },
          currentIndex: navController.idx.value,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket), label: "Laundry Basket"),
            BottomNavigationBarItem(
                icon: Icon(Icons.door_sliding_rounded), label: "Closet"),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_laundry_service), label: "At Wash")
          ],
        ),
      ),
    );
  }
}
