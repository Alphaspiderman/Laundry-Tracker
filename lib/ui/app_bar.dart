import 'package:clothes_tracker/views/create_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({required this.title, Key? key, required this.hasData})
      : super(key: key);
  final String title;

  // Function passed in via constructor to be called when data is saved
  final Function hasData;

  void _hasData() {
    hasData();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle: Get.isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      actions: [
        IconButton(
          onPressed: () async {
            // Create a DB entry taking data from user input
            Get.to(() => DataCaptureScreen(hasData: _hasData));
          },
          icon: const Icon(Icons.add),
        )
        // onPressed: () {
        //   Get.changeThemeMode(
        //       Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
        // },
        // icon: Icon(
        //     Get.isDarkMode ? Icons.dark_mode : Icons.dark_mode_outlined))
      ],
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
    );
  }
}
