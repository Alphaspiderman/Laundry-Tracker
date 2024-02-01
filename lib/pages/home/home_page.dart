import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:clothes_tracker/ui/drawer.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:clothes_tracker/views/create_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DatabaseHelper dbHelper;
  final Logger log = Get.find();

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
    dbHelper = Get.find();
  }

  void _hasData() {
    Get.snackbar(
      'Success',
      'Data saved successfully',
      duration: const Duration(seconds: 1),
    );
    log.d("Data saved successfully");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool isScrolled) {
          return [
            const CustomAppBar(
              title: 'Home',
            ),
          ];
        },
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Show statistics of the app
              FutureBuilder(
                future: dbHelper.getStats(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Text(
                          "Total Items: ${snapshot.data!["Total"]}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          "In Closet: ${snapshot.data!["Closet"]}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          "In Basket: ${snapshot.data!["Basket"]}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          "In Wash: ${snapshot.data!["Wash"]}",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () async {
          Get.to(() => DataCaptureScreen(hasData: _hasData));
        },
      ),
      bottomNavigationBar: const NavBar(itemIndex: 0),
    );
  }
}
