import 'package:clothes_tracker/utils/nav_bar.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CustomBottomNavBar());
  }
}
