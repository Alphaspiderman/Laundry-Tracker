import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBar extends StatefulWidget {
  final int itemIndex;
  final bool showDebug;

  const NavBar({required this.itemIndex, this.showDebug = false, super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    if (widget.showDebug) {
      // Add debug page option in NavBar
      navBarItems.removeLast();
      navBarItems.add(
        IconButton(
          icon: const Icon(Icons.developer_mode),
          tooltip: "Debug",
          onPressed: () =>
              Get.offNamedUntil('/debug', ModalRoute.withName('/home')),
        ),
      );
    }

    // Set color of selected item
    for (int i = 0; i < navBarItems.length; i++) {
      if (i == widget.itemIndex) {
        navBarItems[i] = ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
          child: navBarItems[i],
        );
      }
    }

    // Convert to Row
    Row row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: navBarItems,
    );

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: row.children,
        ),
      ),
    );
  }

  List<Widget> navBarItems = [
    IconButton(
      icon: const Icon(Icons.home),
      tooltip: "Home",
      onPressed: () => Get.back(),
    ),
    IconButton(
      icon: const Icon(Icons.door_sliding_rounded),
      tooltip: "Closet",
      onPressed: () =>
          Get.offNamedUntil('/closet', ModalRoute.withName('/home')),
    ),
    const SizedBox(width: 40),
    IconButton(
      icon: const Icon(Icons.shopping_basket),
      tooltip: "Basket",
      onPressed: () =>
          Get.offNamedUntil('/basket', ModalRoute.withName('/home')),
    ),
    IconButton(
      icon: const Icon(Icons.local_laundry_service),
      tooltip: "At Wash",
      onPressed: () =>
          Get.offNamedUntil('/laundry', ModalRoute.withName('/home')),
    ),
  ];
}
