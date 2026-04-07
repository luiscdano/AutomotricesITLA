import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';
import '../models/api_envelope.dart';
import '../storage/token_storage.dart';

class MultipartFileItem {
  const MultipartFileItem({
    required this.fieldName,
    required this.filePath,
    this.fileName,
  });

  final String fieldName;
  final String filePath;
  final String? fileName;
}

class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    http.Client? httpClient,
  }) : _baseUrl = baseUrl,
       _tokenStorage = tokenStorage,
       _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final TokenStorage _tokenStorage;
final http.Client _httpClient;

  Future<ApiEnvelope> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    final headers = await _buildHeaders(requiresAuth: requiresAuth);
    final uri = _buildUri(path, queryParameters: queryParameters);

    final response = await _httpClient.get(uri, headers: headers);
return _parseResponse(response);
  }

  Future<ApiEnvelope> postDatax(
    String path, {
    required Map<String, dynamic> data,
    bool requiresAuth = false,
  }) async {
    final headers = await _buildHeaders(requiresAuth: requiresAuth);
    headers['Content-Type'] = 'application/x-www-form-urlencoded';

    final uri = _buildUri(path);
    final response = await _httpClient.post(
      uri,
      headers: headers,
      body: {'datax': jsonEncode(data)},
    );

    return _parseResponse(response);
  }

  Future<ApiEnvelope> postMultipartDatax(
    String path, {
    Map<String, dynamic>? data,
    List<MultipartFileItem> files = const [],
    bool requiresAuth = false,
  }) async {
    final headers = await _buildHeaders(requiresAuth: requiresAuth);
    final uri = _buildUri(path);
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(headers);

    if (data != null) {
      request.fields['datax'] = jsonEncode(data);
    }

    for (final item in files) {
      final multipart = await http.MultipartFile.fromPath(
        item.fieldName,
        item.filePath,
        filename: item.fileName,
      );
      request.files.add(multipart);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _parseResponse(response);
  }

  Uri _buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final cleanBaseUrl = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final baseUri = Uri.parse('$cleanBaseUrl$normalizedPath');

    if (queryParameters == null || queryParameters.isEmpty) {
      return baseUri;
    }

    final cleanQuery = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value != null) {
        cleanQuery[key] = value.toString();
      }
    });

    return baseUri.replace(queryParameters: cleanQuery);
  }

  Future<Map<String, String>> _buildHeaders({
    required bool requiresAuth,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (requiresAuth) {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw AppException('No hay una sesion activa.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  ApiEnvelope _parseResponse(http.Response response) {
    Map<String, dynamic> jsonBody;

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        jsonBody = decoded;
      } else {
        jsonBody = {'success': false, 'message': 'Respuesta no valida'};
      }
    } catch (_) {
      throw AppException(
        'El servidor devolvio una respuesta invalida.',
        statusCode: response.statusCode,
      );
    }

    final envelope = ApiEnvelope.fromHttp(
      statusCode: response.statusCode,
      raw: jsonBody,
    );

    final effectiveMessage = envelope.message.isNotEmpty
        ? envelope.message
        : 'La solicitud no pudo completarse.';

    if (response.statusCode >= 400 || envelope.success == false) {
      throw AppException(
        effectiveMessage,
        statusCode: response.statusCode,
        responseData: jsonBody,
      );
    }

    return envelope;
  }
}
