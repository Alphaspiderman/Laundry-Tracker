import 'package:clothes_tracker/models/state.dart';
import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/ui/display_card.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:clothes_tracker/models/db_entry.dart';
import 'package:get/get.dart';

class BasketPage extends StatefulWidget {
  const BasketPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  final DatabaseHelper dbHelper = Get.find();

  void _hasData() {
    Get.snackbar(
      'Success',
      'Data saved successfully',
      duration: const Duration(seconds: 2),
    );
    setState(() {});
  }

  Future<void> _deleteEntry(int id) async {
    Get.dialog(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 30,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Confirm Action",
                      style: TextStyle(fontSize: 26),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Please confirm if you want to remove the following entry",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text(
                              'NO',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final DatabaseHelper dbHelper = Get.find();
                              await dbHelper.deleteData(id);
                              Get.back();
                              Get.snackbar(
                                "Deletion",
                                "Entry Deleted!",
                              );
                              setState(() {});
                            },
                            child: const Text(
                              'YES',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void moveToCloset(int id) async {
    // Use the updateState on database
    await dbHelper.updateState(
      id,
      States.closet,
    );
    // Show a notification
    Get.snackbar(
      'Success',
      'Item moved to Closet',
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
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool isScrolled) {
          return [
            CustomAppBar(
              title: 'Basket',
              hasData: _hasData,
            ),
          ];
        },
        body: FutureBuilder(
          future: dbHelper.fetchDataByState(States.basket),
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
                    onFirstButtonPressed: moveToCloset,
                    onSecondButtonPressed: moveToLaundry,
                    onDelete: (int id) async {
                      await _deleteEntry(id);
                    },
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const NavBar(itemIndex: 2),
    );
  }
}
