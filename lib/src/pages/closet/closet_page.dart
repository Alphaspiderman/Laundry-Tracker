import 'package:clothes_tracker/src/models/db_entry.dart';
import 'package:clothes_tracker/src/models/state.dart';
import 'package:clothes_tracker/src/navigation/navgation_bar.dart';
import 'package:clothes_tracker/src/ui/app_bar.dart';
import 'package:clothes_tracker/src/ui/common_page_layout.dart';
import 'package:clothes_tracker/src/ui/drawer.dart';
import 'package:clothes_tracker/src/utils/app_page_controller.dart';
import 'package:clothes_tracker/src/views/create_entry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClosetPage extends GetWidget<AppPageController> {
  const ClosetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Scaffold(
      drawer: const AppDrawer(),
      body: NestedScrollView(
        key: const PageStorageKey(States.closet),
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool isScrolled) {
          return [
            const CustomAppBar(
              title: 'Closet',
            ),
          ];
        },
        body: GetBuilder<AppPageController>(
          builder: (controller) {
            return FutureBuilder(
              future: controller.getData(States.closet),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                } else {
                  List<DbEntry> data = snapshot.data as List<DbEntry>;

                  if (data.isEmpty) {
                    return const Center(
                      child: Text(
                        "Closet is Empty",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return CommonPageLayout(
                    categoryMap: controller.categoryMap,
                    controller: controller,
                    data: data,
                    scrollController: scrollController,
                  );
                }
              },
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () async {
          Get.to(() => DataCaptureScreen(hasData: controller.hasData));
        },
      ),
      bottomNavigationBar: const NavBar(itemIndex: 1),
    );
  }
}
