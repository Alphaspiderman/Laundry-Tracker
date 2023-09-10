import 'package:clothes_tracker/pages/basket/basket_page.dart';
import 'package:clothes_tracker/pages/closet/closet_page.dart';
import 'package:clothes_tracker/pages/home/home_page.dart';
import 'package:clothes_tracker/pages/laundry/laundry_page.dart';
import 'package:clothes_tracker/pages/debug/debug.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBar extends StatelessWidget {
  final int itemIndex;
  final bool debug;

  const NavBar({required this.itemIndex, this.debug = false, super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const HomePage(),
      const ClosetPage(),
      const BasketPage(),
    ];
    if (debug) {
      pages.add(const DebugPage());
    } else {
      pages.add(const LaundryPage());
    }

    return BottomNavigationBar(
      currentIndex: itemIndex,
      onTap: (index) {
        // Navigate via GetX
        Get.offAll(pages[index]);
      },
      items: getNavBarItems(debug),
      selectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
    );
  }

  List<BottomNavigationBarItem> getNavBarItems(bool debug) {
    List<BottomNavigationBarItem> items = const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(
          icon: Icon(Icons.door_sliding_rounded), label: "Closet"),
      BottomNavigationBarItem(
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
