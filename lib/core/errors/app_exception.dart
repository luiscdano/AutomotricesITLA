class AppException implements Exception {
  AppException(this.message, {this.statusCode, this.responseData});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  @override
  String toString() {
    final code = statusCode != null ? ' (HTTP $statusCode)' : '';
    return 'AppException$code: $message';
  }
}
