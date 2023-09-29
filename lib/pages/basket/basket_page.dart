import 'package:clothes_tracker/models/state.dart';
import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/ui/display_card.dart';
import 'package:clothes_tracker/views/create_entry.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Material(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        //Buttons
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
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
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
      appBar: const CustomAppBar(
        title: "Basket",
      ),
      // Add a FAB to create DB entry
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Create a DB entry taking data from user input
          Get.to(() => DataCaptureScreen(hasData: _hasData));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const NavBar(itemIndex: 2),
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
    );
  }
}
