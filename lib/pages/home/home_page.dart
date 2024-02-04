import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/pages/home/home_controller.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:clothes_tracker/ui/drawer.dart';
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
  final Logger log = Get.find();

  final HomeController homeController = HomeController();

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
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
      drawer: const AppDrawer(),
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
          child: FutureBuilder<Column>(
            future: homeController.getBody(),
            builder: (BuildContext context, AsyncSnapshot<Column> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const CircularProgressIndicator();
            },
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
