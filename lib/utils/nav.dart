import 'package:clothes_tracker/pages/basket_page.dart';
import 'package:clothes_tracker/pages/closet_page.dart';
import 'package:clothes_tracker/pages/home_page.dart';
import 'package:clothes_tracker/pages/laundry_page.dart';
import 'package:flutter/material.dart';

class PageWithNavBar extends StatefulWidget {
  const PageWithNavBar({super.key});

  @override
  _PageWithNavBarState createState() => _PageWithNavBarState();
}

class _PageWithNavBarState extends State<PageWithNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const BasketPage(),
    const ClosetPage(),
    const LaundryPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket), label: "Laundry Basket"),
          BottomNavigationBarItem(
              icon: Icon(Icons.door_sliding_rounded), label: "Closet"),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_laundry_service), label: "At Wash")
        ],
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      ),
    );
  }
}
