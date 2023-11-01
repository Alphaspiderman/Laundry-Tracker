// Your controller class
import 'package:clothes_tracker/utils/db.dart';
import 'package:get/get.dart';

class DBController extends GetxController {
  late DatabaseHelper _db;

  // Initialize your class
  void initClass() async {
    _db = DatabaseHelper();
    await _db.initClass();
  }

  DatabaseHelper get db => _db;
}
