import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/pages/debug/debug_controller.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:clothes_tracker/ui/drawer.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
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
