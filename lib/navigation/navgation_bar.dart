import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBar extends StatelessWidget {
  final int itemIndex;

  const NavBar({required this.itemIndex, super.key});

  @override
  Widget build(BuildContext context) {
    List<String> pages = [
      '/home',
      '/closet',
      '/basket',
      '/laundry',
    ];

    return BottomNavigationBar(
      currentIndex: itemIndex,
      onTap: (index) {
        if (itemIndex != 0) {
          Get.back();
        }
        Get.toNamed(pages[index]);
      },
      items: navBarItems,
      selectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
    );
  }

  static const navBarItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(
        icon: Icon(Icons.door_sliding_rounded), label: "Closet"),
    BottomNavigationBarItem(
        icon: Icon(Icons.shopping_basket), label: "Laundry Basket"),
    BottomNavigationBarItem(
        icon: Icon(Icons.local_laundry_service), label: "At Wash"),
  ];
}
