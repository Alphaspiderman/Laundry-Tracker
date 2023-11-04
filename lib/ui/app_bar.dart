import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({required this.title, Key? key}) : super(key: key);
  final String title;

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
          onPressed: () {
            Get.changeThemeMode(
                Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
          },
          icon:
              Icon(Get.isDarkMode ? Icons.dark_mode : Icons.dark_mode_outlined),
        )
      ],
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
    );
  }
}
