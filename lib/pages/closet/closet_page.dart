import 'dart:io';
import 'package:clothes_tracker/models/state.dart';
import 'package:clothes_tracker/models/status.dart';
import 'package:clothes_tracker/navigation/navgation_bar.dart';
import 'package:clothes_tracker/views/create_entry.dart';
import 'package:clothes_tracker/ui/app_bar.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:clothes_tracker/models/db_entry.dart';
import 'package:get/get.dart';

class ClosetPage extends StatefulWidget {
  const ClosetPage({super.key});

  @override
  _ClosetPageState createState() => _ClosetPageState();
}

class _ClosetPageState extends State<ClosetPage> {
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    dbHelper.initDatabase();
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
          // Create a DB entry taking data from user input
          Status snack = await Get.to(() => const DataCaptureScreen());
          switch (snack) {
            case Status.success:
              Get.snackbar(
                'Success',
                'Data saved successfully',
              );
              break;
            default:
          }
          setState(() {});
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
                // Create a card with the image and name
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(dataList[index].name),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Image.file(
                          File(dataList[index].imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      ButtonBar(
                        children: [
                          OutlinedButton(
                            child: const Text('Move to Basket'),
                            onPressed: () async {
                              // Use the updateState on database
                              await dbHelper.updateState(
                                dataList[index].id,
                                States.basket,
                              );
                              // Show a notification
                              Get.snackbar(
                                'Success',
                                'Item moved to basket',
                                duration: const Duration(seconds: 3),
                              );
                              // Rebuild the view
                              setState(() {});
                            },
                          ),
                          OutlinedButton(
                            child: const Text('Send to Laundry'),
                            onPressed: () async {
                              // Use the updateState on database
                              await dbHelper.updateState(
                                dataList[index].id,
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
                            },
                          )
                        ],
                      )
                    ],
                  ),
                );

                // return Card(
                //   child: ListTile(
                //     leading: Image.file(File(dataList[index].imagePath)),
                //     title: Text(dataList[index].name),
                //     subtitle: Text(dataList[index].state.toString()),
                //   ),
                // );
              },
            );
          }
        },
      ),
    );
  }
}
