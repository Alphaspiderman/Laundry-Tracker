import 'package:get/get.dart';

class SnackbarManager {
  static final SnackbarManager _instance = SnackbarManager._internal();
  factory SnackbarManager() => _instance;
  SnackbarManager._internal();

  final List<GetSnackBar> _snackbarQueue = [];
  bool _isShowing = false;

  void showSnackbar(GetSnackBar snackbar) {
    if (_snackbarQueue.length < 2) {
      _snackbarQueue.add(snackbar);
      _showNextSnackbar();
    }
  }

  void _showNextSnackbar() {
    if (!_isShowing && _snackbarQueue.isNotEmpty) {
      _isShowing = true;
      Get.showSnackbar(_snackbarQueue.removeAt(0)).future.then((_) {
        _isShowing = false;
        _showNextSnackbar();
      });
    }
  }
}
