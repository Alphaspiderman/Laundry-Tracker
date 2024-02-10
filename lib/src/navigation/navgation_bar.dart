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
      // Remove the empty space in the center
      navBarItems.removeAt(2);
      // Add debug page option in the center
      navBarItems.insert(
        2,
        IconButton(
          icon: const Icon(Icons.bug_report),
          tooltip: "Debug",
          onPressed: () => Get.offAllNamed('/debug'),
        ),
      );
    }

    // Set color of selected item
    for (int i = 0; i < navBarItems.length; i++) {
      if (i == widget.itemIndex) {
        navBarItems[i] = ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.purple.shade300,
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
      onPressed: () => Get.offAllNamed('/home'),
    ),
    IconButton(
      icon: const Icon(Icons.door_sliding_rounded),
      tooltip: "Closet",
      onPressed: () => Get.offAllNamed('/closet'),
    ),
    const SizedBox(width: 40),
    IconButton(
      icon: const Icon(Icons.shopping_basket),
      tooltip: "Basket",
      onPressed: () => Get.offAllNamed('/basket'),
    ),
    IconButton(
      icon: const Icon(Icons.local_laundry_service),
      tooltip: "At Wash",
      onPressed: () => Get.offAllNamed('/laundry'),
    ),
  ];
}
