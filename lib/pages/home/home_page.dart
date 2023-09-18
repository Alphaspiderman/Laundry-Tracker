import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DatabaseHelper dbHelper;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
    dbHelper = Get.find();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Home",
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                Get.snackbar("Test", "Hello!");
              },
              child: const Text('Trigger Snack'),
            ),
            // Add a button to purge the DB
            OutlinedButton(
              onPressed: () async {
                await dbHelper.purgeData();
                Get.snackbar("Purge", "DB Purged!");
              },
              child: const Text('Purge DB'),
            ),
            // Add a button to toggle debug page
            OutlinedButton(
              onPressed: () {
                Get.toNamed("/debug");
              },
              child: const Text('Debug Page'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(itemIndex: 0),
    );
  }
}
