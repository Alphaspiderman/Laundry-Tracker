import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/pages/closet/closet_controller.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:clothes_tracker/views/create_entry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClosetPage extends StatefulWidget {
  const ClosetPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClosetPageState createState() => _ClosetPageState();
}

class _ClosetPageState extends State<ClosetPage> {
  final ClosetController closetController = ClosetController();

  @override
  void initState() {
    super.initState();
    closetController.addListener(() {
      setState(() {});
    });
  }

  void _hasData() {
    Get.snackbar(
      'Success',
      'Data saved successfully',
      duration: const Duration(seconds: 1),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool isScrolled) {
          return [
            const CustomAppBar(
              title: 'Closet',
            ),
          ];
        },
        body: closetController.getBody(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () async {
          Get.to(() => DataCaptureScreen(hasData: _hasData));
        },
      ),
      bottomNavigationBar: const NavBar(itemIndex: 1),
    );
  }
}
