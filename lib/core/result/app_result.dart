class AppResult<T> {
  const AppResult._({this.data, this.errorMessage, this.errorCode});

  final T? data;
  final String? errorMessage;
  final String? errorCode;

  bool get isSuccess => errorMessage == null;
  bool get isFailure => !isSuccess;

  static AppResult<T> success<T>(T data) => AppResult<T>._(data: data);

  static AppResult<T> failure<T>(String message, {String? code}) =>
      AppResult<T>._(errorMessage: message, errorCode: code);
}
