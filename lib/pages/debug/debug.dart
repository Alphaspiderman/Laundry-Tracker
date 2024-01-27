import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/pages/debug/debug_controller.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DebugPageState createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final DebugController debugController = DebugController();

  @override
  void initState() {
    super.initState();
    debugController.addListener(() {
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
              title: 'Debug Page',
            ),
          ];
        },
        body: debugController.getBody(),
      ),
      bottomNavigationBar: const NavBar(itemIndex: 2, showDebug: true),
    );
  }
}
