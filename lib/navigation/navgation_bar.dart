import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBar extends StatelessWidget {
  final int itemIndex;
  final bool debug;

  const NavBar({required this.itemIndex, this.debug = false, super.key});

  @override
  Widget build(BuildContext context) {
    List<String> pages = [
      '/home',
      '/closet',
      '/basket',
    ];
    if (debug) {
      pages.add('/debug');
    } else {
      pages.add('/laundry');
    }

    return BottomNavigationBar(
      currentIndex: itemIndex,
      onTap: (index) {
        if (itemIndex != 0) {
          Get.back();
        }
        Get.toNamed(pages[index]);
      },
      items: getNavBarItems(debug),
      selectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
    );
  }

  List<BottomNavigationBarItem> getNavBarItems(bool debug) {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.door_sliding_rounded), label: "Closet"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket), label: "Laundry Basket"),
    ];
    if (debug) {
      items.add(
        const BottomNavigationBarItem(
            icon: Icon(Icons.bug_report), label: "Debug Page"),
      );
    } else {
      items.add(
        const BottomNavigationBarItem(
            icon: Icon(Icons.local_laundry_service), label: "At Wash"),
      );
    }
    return items;
  }
}
