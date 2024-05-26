import 'package:clothes_tracker/src/navigation/navgation_bar.dart';
import 'package:clothes_tracker/src/pages/debug/debug_controller.dart';
import 'package:clothes_tracker/src/ui/app_bar.dart';
import 'package:clothes_tracker/src/ui/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DebugPage extends GetWidget<DebugController> {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool isScrolled) {
          return [
            const CustomAppBar(
              title: 'Debug Page',
            ),
          ];
        },
        body: controller.getBody(),
      ),
      bottomNavigationBar: const NavBar(itemIndex: 2, showDebug: true),
    );
  }
}
