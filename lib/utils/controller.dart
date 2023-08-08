// Your controller class
import 'package:get/get.dart';
import 'package:clothes_tracker/utils/db.dart';

class DBController extends GetxController {
  late DatabaseHelper _db;

  // Initialize your class
  void initClass() {
    _db = DatabaseHelper();
  }

  DatabaseHelper get db => _db;
}
