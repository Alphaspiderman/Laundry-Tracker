// Custom exception class for database errors
class DbException implements Exception {
  final String message;

  DbException(this.message);

  @override
  String toString() {
    return 'DbException: $message';
  }

  // Get message
  String getMessage() {
    return message;
  }
}
