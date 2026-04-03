import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/result/app_result.dart';
import '../models/private_models.dart';
import 'private_repository.dart';

class PrivateRepositoryImpl implements PrivateRepository {
  PrivateRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<AppResult<UserProfile>> fetchProfile() async {
    try {
      final envelope = await _apiClient.get('/perfil', requiresAuth: true);
      return AppResult.success(UserProfile.fromMap(_asMap(envelope.data)));
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible cargar el perfil.');
    }
  }

  @override
  Future<AppResult<String>> uploadProfilePhoto({
    required String filePath,
  }) async {
    try {
      final envelope = await _apiClient.postMultipartDatax(
        '/perfil/foto',
        requiresAuth: true,
        files: [MultipartFileItem(fieldName: 'foto', filePath: filePath)],
      );

      final data = _asMap(envelope.data);
      final url = _toStr(data['fotoUrl']);

      return AppResult.success(url);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible actualizar la foto de perfil.');
    }
  }

  @override
  Future<AppResult<VehiclePage>> fetchVehicles({
    int page = 1,
    int limit = 20,
    String? marca,
    String? modelo,
  }) async {
    try {
      final envelope = await _apiClient.get(
        '/vehiculos',
        requiresAuth: true,
        queryParameters: {
          'page': page,
          'limit': limit,
          'marca': marca,
          'modelo': modelo,
        },
      );

      final items = _asMapList(envelope.data).map(VehicleItem.fromMap).toList();

      return AppResult.success(
        VehiclePage(
          items: items,
          page: _toInt(envelope.raw['page'], fallback: page),
          limit: _toInt(envelope.raw['limit'], fallback: limit),
          total: _toInt(envelope.raw['total'], fallback: items.length),
        ),
      );
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible cargar los vehiculos.');
    }
  }

  @override
  Future<AppResult<VehicleItem>> createVehicle({
    required VehicleInput input,
    String? photoPath,
  }) async {
    try {
      final datax = {
        'placa': input.placa,
        'chasis': input.chasis,
        'marca': input.marca,
        'modelo': input.modelo,
        'anio': input.anio,
        'cantidadRuedas': input.cantidadRuedas,
      };

      final envelope = await _apiClient.postMultipartDatax(
        '/vehiculos',
        requiresAuth: true,
        data: datax,
        files: (photoPath != null && photoPath.isNotEmpty)
            ? [MultipartFileItem(fieldName: 'foto', filePath: photoPath)]
            : const [],
      );

      return AppResult.success(VehicleItem.fromMap(_asMap(envelope.data)));
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible registrar el vehiculo.');
    }
  }

  @override
  Future<AppResult<VehicleItem>> updateVehicle({
    required int id,
    required VehicleInput input,
  }) async {
    try {
      final envelope = await _apiClient.postDatax(
        '/vehiculos/editar',
        requiresAuth: true,
        data: {
          'id': id,
          'placa': input.placa,
          'chasis': input.chasis,
          'marca': input.marca,
          'modelo': input.modelo,
          'anio': input.anio,
          'cantidadRuedas': input.cantidadRuedas,
        },
      );

      return AppResult.success(VehicleItem.fromMap(_asMap(envelope.data)));
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible actualizar el vehiculo.');
    }
  }

  @override
  Future<AppResult<String>> uploadVehiclePhoto({
    required int id,
    required String filePath,
  }) async {
    try {
      final envelope = await _apiClient.postMultipartDatax(
        '/vehiculos/foto',
        requiresAuth: true,
        data: {'id': id},
        files: [MultipartFileItem(fieldName: 'foto', filePath: filePath)],
      );

      final data = _asMap(envelope.data);
      final url = _toStr(data['fotoUrl']);
      return AppResult.success(url);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure(
        'No fue posible actualizar la foto del vehiculo.',
      );
    }
  }

  @override
  Future<AppResult<VehicleDetail>> fetchVehicleDetail({required int id}) async {
    try {
      final envelope = await _apiClient.get(
        '/vehiculos/detalle',
        requiresAuth: true,
        queryParameters: {'id': id},
      );

      return AppResult.success(VehicleDetail.fromMap(_asMap(envelope.data)));
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure(
        'No fue posible cargar el detalle del vehiculo.',
      );
    }
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
        .map((item) => item.map((key, val) => MapEntry(key.toString(), val)))
        .toList();
  }

  int _toInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _toStr(dynamic value) => value?.toString() ?? '';
}
