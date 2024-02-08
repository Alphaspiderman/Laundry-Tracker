import 'package:clothes_tracker/src/pages/basket/basket_page.dart';
import 'package:clothes_tracker/src/pages/categories/manage_category_page.dart';
import 'package:clothes_tracker/src/pages/closet/closet_page.dart';
import 'package:clothes_tracker/src/pages/debug/debug.dart';
import 'package:clothes_tracker/src/pages/home/home_page.dart';
import 'package:clothes_tracker/src/pages/laundry/laundry_page.dart';
import 'package:clothes_tracker/src/themes/dark.dart';
import 'package:clothes_tracker/src/themes/light.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LaundryApp extends StatelessWidget {
  const LaundryApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Laundry Tracker',
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system,
      // home: const HomePage(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/closet', page: () => const ClosetPage()),
        GetPage(name: '/basket', page: () => const BasketPage()),
        GetPage(name: '/laundry', page: () => const LaundryPage()),
        GetPage(name: '/debug', page: () => const DebugPage()),
        GetPage(name: '/categories', page: () => const ManageCategoryPage()),
      ],
    );
  }
}
