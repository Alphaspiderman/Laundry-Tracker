import 'package:clothes_tracker/models/category.dart';
import 'package:clothes_tracker/utils/db.dart';
import 'package:get/get.dart';

class CategoriesController extends GetxController {
  final DatabaseHelper dbHelper = Get.find();

  Future<void> handleCategoryDelete(int categoryId) async {
    // Delete the category
    bool deleted = await dbHelper.deleteCategory(categoryId);
    if (!deleted && categoryId == 1) {
      Get.snackbar(
        'Error',
        'Cannot delete the Default category',
        duration: const Duration(seconds: 1),
      );
      return;
    }
    if (!deleted) {
      Get.snackbar(
        'Error',
        'Unable to delete the category',
        duration: const Duration(seconds: 1),
      );
      return;
    }
    // Refresh the list
    List<Category> list = await dbHelper.fetchCategories();
    Get.find<List<Category>>().assignAll(list);
    dbHelper.refreshAll();
    // Go back to the previous screen
    Get.back();
    // Show a notification
    Get.snackbar(
      'Success',
      'Category deleted successfully',
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> handleCategoryCreate(String text) async {
    // Check if the name already exists
    if (await dbHelper.checkCategory(text)) {
      Get.snackbar(
        'Error',
        'Category already exists',
        duration: const Duration(seconds: 1),
      );
      return;
    }
    // Create the category
    await dbHelper.addCategory(text);
    // Refresh the list
    List<Category> list = await dbHelper.fetchCategories();
    Get.find<List<Category>>().assignAll(list);
    dbHelper.refreshAll();
    // Go back to the previous screen
    Get.back();
    // Show a notification
    Get.snackbar(
      'Success',
      'Category created successfully',
      duration: const Duration(seconds: 1),
    );
  }
}
