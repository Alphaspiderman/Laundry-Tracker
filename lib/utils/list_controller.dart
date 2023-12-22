import 'package:clothes_tracker/models/db_entry.dart';
import 'package:clothes_tracker/models/state.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:get/get.dart';

class ListController extends GetxController {
  final DatabaseHelper dbHelper = Get.find();
  var items = List<dynamic>.empty().obs;

  // Function to remove an item from the list
  void removeItem(int index) {
    items.removeAt(index);
  }

  // Function to update the list in the controller from the database
  Future<void> refreshData(States states) async {
    // Get the data from the database
    final List<DbEntry> data = await dbHelper.fetchDataByState(states);
    // Update the list in the controller
    items.value = data;
  }
}
