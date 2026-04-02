class ApiEnvelope {
  ApiEnvelope({
    required this.success,
    required this.message,
    required this.data,
    required this.statusCode,
    required this.raw,
  });

  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;
  final Map<String, dynamic> raw;

  factory ApiEnvelope.fromHttp({
    required int statusCode,
    required Map<String, dynamic> raw,
  }) {
    return ApiEnvelope(
      success: raw['success'] == true,
      message: raw['message']?.toString() ?? '',
      data: raw['data'],
      statusCode: statusCode,
      raw: raw,
    );
  }
}
