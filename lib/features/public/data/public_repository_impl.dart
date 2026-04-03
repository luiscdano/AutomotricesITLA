import '../../../core/errors/app_exception.dart';
import '../../../core/models/api_envelope.dart';
import '../../../core/network/api_client.dart';
import '../../../core/result/app_result.dart';
import '../models/public_models.dart';
import 'public_repository.dart';

class PublicRepositoryImpl implements PublicRepository {
  PublicRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<AppResult<List<NewsItem>>> fetchNews() async {
    try {
      final envelope = await _getPublicThenProtected(
        publicPath: '/publico/noticias',
        protectedPath: '/noticias',
      );

      final items = _asMapList(envelope.data).map(NewsItem.fromMap).toList();
      return AppResult.success(items);
    } on AppException catch (error) {
      return AppResult.failure(_normalizePublicError(error));
    } catch (_) {
      return AppResult.failure('No fue posible cargar las noticias.');
    }
  }

  @override
  Future<AppResult<NewsDetail>> fetchNewsDetail({required int id}) async {
    try {
      final envelope = await _getPublicThenProtected(
        publicPath: '/publico/noticias/detalle',
        protectedPath: '/noticias/detalle',
        queryParameters: {'id': id},
      );

      final detail = NewsDetail.fromMap(_asMap(envelope.data));
      return AppResult.success(detail);
    } on AppException catch (error) {
      return AppResult.failure(_normalizePublicError(error));
    } catch (_) {
      return AppResult.failure(
        'No fue posible cargar el detalle de la noticia.',
      );
    }
  }

  @override
  Future<AppResult<List<VideoItem>>> fetchVideos() async {
    try {
      final envelope = await _getPublicThenProtected(
        publicPath: '/publico/videos',
        protectedPath: '/videos',
      );

      final items = _asMapList(envelope.data).map(VideoItem.fromMap).toList();
      return AppResult.success(items);
    } on AppException catch (error) {
      return AppResult.failure(_normalizePublicError(error));
    } catch (_) {
      return AppResult.failure('No fue posible cargar los videos.');
    }
  }

  @override
  Future<AppResult<CatalogPage>> fetchCatalog({
    int page = 1,
    int limit = 20,
    String? marca,
    String? modelo,
    int? anio,
  }) async {
    try {
      final envelope = await _getProtectedWithAuthFallback(
        '/catalogo',
        queryParameters: {
          'page': page,
          'limit': limit,
          'marca': marca,
          'modelo': modelo,
          'anio': anio,
        },
      );

      final items = _asMapList(envelope.data).map(CatalogItem.fromMap).toList();

      return AppResult.success(
        CatalogPage(
          items: items,
          page: _toInt(envelope.raw['page'], fallback: page),
          limit: _toInt(envelope.raw['limit'], fallback: limit),
          total: _toInt(envelope.raw['total'], fallback: items.length),
        ),
      );
    } on AppException catch (error) {
      return AppResult.failure(_normalizePublicError(error));
    } catch (_) {
      return AppResult.failure('No fue posible cargar el catalogo.');
    }
  }

  @override
  Future<AppResult<CatalogDetail>> fetchCatalogDetail({required int id}) async {
    try {
      final envelope = await _getProtectedWithAuthFallback(
        '/catalogo/detalle',
        queryParameters: {'id': id},
      );

      final detail = CatalogDetail.fromMap(_asMap(envelope.data));
      return AppResult.success(detail);
    } on AppException catch (error) {
      return AppResult.failure(_normalizePublicError(error));
    } catch (_) {
      return AppResult.failure(
        'No fue posible cargar el detalle del vehiculo.',
      );
    }
  }

  @override
  Future<AppResult<List<ForumTopic>>> fetchPublicForum({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final envelope = await _apiClient.get(
        '/publico/foro',
        queryParameters: {'page': page, 'limit': limit},
      );

      final items = _asMapList(envelope.data).map(ForumTopic.fromMap).toList();
      return AppResult.success(items);
    } on AppException catch (error) {
      return AppResult.failure(_normalizePublicError(error));
    } catch (_) {
      return AppResult.failure('No fue posible cargar el foro publico.');
    }
  }

  @override
  Future<AppResult<ForumDetail>> fetchPublicForumDetail({
    required int id,
  }) async {
    try {
      final envelope = await _apiClient.get(
        '/publico/foro/detalle',
        queryParameters: {'id': id},
      );

      final detail = ForumDetail.fromMap(_asMap(envelope.data));
      return AppResult.success(detail);
    } on AppException catch (error) {
      return AppResult.failure(_normalizePublicError(error));
    } catch (_) {
      return AppResult.failure('No fue posible cargar el tema del foro.');
    }
  }

  Future<ApiEnvelope> _getPublicThenProtected({
    required String publicPath,
    required String protectedPath,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _apiClient.get(publicPath, queryParameters: queryParameters);
    } on AppException catch (publicError) {
      final shouldTryProtected =
          publicError.statusCode == 401 || publicError.statusCode == 404;
      if (!shouldTryProtected) {
        rethrow;
      }
      return _getProtectedWithAuthFallback(
        protectedPath,
        queryParameters: queryParameters,
      );
    }
  }

  Future<ApiEnvelope> _getProtectedWithAuthFallback(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _apiClient.get(path, queryParameters: queryParameters);
    } on AppException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }

      try {
        return await _apiClient.get(
          path,
          queryParameters: queryParameters,
          requiresAuth: true,
        );
      } on AppException catch (authError) {
        throw AppException(
          _requiresSessionMessage(authError.message),
          statusCode: authError.statusCode,
          responseData: authError.responseData,
        );
      }
    }
  }

  String _normalizePublicError(AppException error) {
    if (error.statusCode == 401) {
      return _requiresSessionMessage(error.message);
    }
    return error.message;
  }

  String _requiresSessionMessage(String backendMessage) {
    return '$backendMessage. Este modulo requiere sesion activa en este backend. Inicia sesion para continuar.';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];

    return value
        .whereType<Map>()
        .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  int _toInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
