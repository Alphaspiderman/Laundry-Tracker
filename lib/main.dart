import 'package:clothes_tracker/pages/basket/basket_page.dart';
import 'package:clothes_tracker/pages/closet/closet_page.dart';
import 'package:clothes_tracker/pages/debug/debug.dart';
import 'package:clothes_tracker/pages/home/home_page.dart';
import 'package:clothes_tracker/pages/laundry/laundry_page.dart';
import 'package:clothes_tracker/utils/controller.dart';
import 'package:flutter/material.dart';
import 'package:clothes_tracker/themes/dark.dart';
import 'package:clothes_tracker/themes/light.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  DBController db = DBController();
  db.initClass();
  Get.put(db.db);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      ],
    );
  }
}
