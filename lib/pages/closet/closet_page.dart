import 'package:clothes_tracker/models/state.dart';
import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/ui/display_card.dart';
import 'package:clothes_tracker/views/create_entry.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:clothes_tracker/models/db_entry.dart';
import 'package:get/get.dart';

class ClosetPage extends StatefulWidget {
  const ClosetPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClosetPageState createState() => _ClosetPageState();
}

class _ClosetPageState extends State<ClosetPage> {
  final DatabaseHelper dbHelper = Get.find();

  void _hasData() {
    Get.snackbar(
      'Success',
      'Data saved successfully',
      duration: const Duration(seconds: 2),
    );
    setState(() {});
  }

  void moveToBasket(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.basket,
    );
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Basket',
      duration: const Duration(seconds: 3),
    );
    // Rebuild the view
    setState(() {});
  }

  void moveToLaundry(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.wash,
    );
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Laundry',
      duration: const Duration(seconds: 3),
    );
    // Rebuild the view
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Closet",
      ),
      bottomNavigationBar: const NavBar(itemIndex: 1),
      // Add a FAB to create DB entry
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Get.to(() => DataCaptureScreen(hasData: _hasData));
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: dbHelper.fetchDataByState(States.closet),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              heightFactor: 10,
              widthFactor: 10,
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Display details about data
            // return Text('Data: ${snapshot.data}');
            List<DbEntry> dataList = snapshot.data as List<DbEntry>;
            // Display the items in list as cards
            return ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                // return a display card
                return DisplayCard(
                  data: dataList[index],
                  onFirstButtonPressed: moveToBasket,
                  onSecondButtonPressed: moveToLaundry,
                );
              },
            );
          }
        },
      ),
    );
  }
}
