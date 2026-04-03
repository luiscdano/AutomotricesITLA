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

  @override
  Future<AppResult<List<MaintenanceRecord>>> fetchMaintenances({
    required int vehiculoId,
    String? tipo,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final envelope = await _apiClient.get(
        '/mantenimientos',
        requiresAuth: true,
        queryParameters: {
          'vehiculo_id': vehiculoId,
          'tipo': tipo,
          'page': page,
          'limit': limit,
        },
      );

      final items = _asMapList(
        envelope.data,
      ).map(MaintenanceRecord.fromMap).toList();
      return AppResult.success(items);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible cargar los mantenimientos.');
    }
  }

  @override
  Future<AppResult<MaintenanceRecord>> createMaintenance({
    required MaintenanceInput input,
    List<String> photoPaths = const [],
  }) async {
    try {
      final data = <String, dynamic>{
        'vehiculo_id': input.vehiculoId,
        'tipo': input.tipo,
        'costo': input.costo,
      };

      if ((input.piezas ?? '').trim().isNotEmpty) {
        data['piezas'] = input.piezas!.trim();
      }
      if ((input.fecha ?? '').trim().isNotEmpty) {
        data['fecha'] = input.fecha!.trim();
      }

      final envelope = await _apiClient.postMultipartDatax(
        '/mantenimientos',
        requiresAuth: true,
        data: data,
        files: _fileList(photoPaths, fieldName: 'fotos[]'),
      );

      return AppResult.success(
        MaintenanceRecord.fromMap(_asMap(envelope.data)),
      );
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible registrar el mantenimiento.');
    }
  }

  @override
  Future<AppResult<MaintenanceRecord>> fetchMaintenanceDetail({
    required int id,
  }) async {
    try {
      final envelope = await _apiClient.get(
        '/mantenimientos/detalle',
        requiresAuth: true,
        queryParameters: {'id': id},
      );

      return AppResult.success(
        MaintenanceRecord.fromMap(_asMap(envelope.data)),
      );
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure(
        'No fue posible cargar el detalle del mantenimiento.',
      );
    }
  }

  @override
  Future<AppResult<List<String>>> uploadMaintenancePhotos({
    required int maintenanceId,
    required List<String> photoPaths,
  }) async {
    try {
      final envelope = await _apiClient.postMultipartDatax(
        '/mantenimientos/fotos',
        requiresAuth: true,
        data: {'mantenimiento_id': maintenanceId},
        files: _fileList(photoPaths, fieldName: 'fotos[]'),
      );

      final data = _asMap(envelope.data);
      final photosRaw = data['fotos'];
      final photos = photosRaw is List
          ? photosRaw.map((item) => item.toString()).toList()
          : <String>[];
      return AppResult.success(photos);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure(
        'No fue posible subir las fotos del mantenimiento.',
      );
    }
  }

  @override
  Future<AppResult<List<FuelRecord>>> fetchFuelRecords({
    required int vehiculoId,
    String? tipo,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final envelope = await _apiClient.get(
        '/combustibles',
        requiresAuth: true,
        queryParameters: {
          'vehiculo_id': vehiculoId,
          'tipo': tipo,
          'page': page,
          'limit': limit,
        },
      );

      final items = _asMapList(envelope.data).map(FuelRecord.fromMap).toList();
      return AppResult.success(items);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure(
        'No fue posible cargar los consumos de combustible y aceite.',
      );
    }
  }

  @override
  Future<AppResult<FuelRecord>> createFuelRecord({
    required FuelInput input,
  }) async {
    try {
      final envelope = await _apiClient.postDatax(
        '/combustibles',
        requiresAuth: true,
        data: {
          'vehiculo_id': input.vehiculoId,
          'tipo': input.tipo,
          'cantidad': input.cantidad,
          'unidad': input.unidad,
          'monto': input.monto,
        },
      );

      return AppResult.success(FuelRecord.fromMap(_asMap(envelope.data)));
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible registrar el consumo.');
    }
  }

  @override
  Future<AppResult<TireState>> fetchTireState({required int vehiculoId}) async {
    try {
      final envelope = await _apiClient.get(
        '/gomas',
        requiresAuth: true,
        queryParameters: {'vehiculo_id': vehiculoId},
      );

      return AppResult.success(TireState.fromMap(_asMap(envelope.data)));
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible cargar el estado de las gomas.');
    }
  }

  @override
  Future<AppResult<TireStatus>> updateTireStatus({
    required int tireId,
    required String estado,
  }) async {
    try {
      final envelope = await _apiClient.postDatax(
        '/gomas/actualizar',
        requiresAuth: true,
        data: {'goma_id': tireId, 'estado': estado},
      );

      return AppResult.success(TireStatus.fromMap(_asMap(envelope.data)));
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure(
        'No fue posible actualizar el estado de la goma.',
      );
    }
  }

  @override
  Future<AppResult<TirePuncture>> registerTirePuncture({
    required int tireId,
    String? descripcion,
    String? fecha,
  }) async {
    try {
      final data = <String, dynamic>{'goma_id': tireId};

      if ((descripcion ?? '').trim().isNotEmpty) {
        data['descripcion'] = descripcion!.trim();
      }
      if ((fecha ?? '').trim().isNotEmpty) {
        data['fecha'] = fecha!.trim();
      }

      final envelope = await _apiClient.postDatax(
        '/gomas/pinchazos',
        requiresAuth: true,
        data: data,
      );

      return AppResult.success(TirePuncture.fromMap(_asMap(envelope.data)));
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible registrar el pinchazo.');
    }
  }

  @override
  Future<AppResult<List<ExpenseCategory>>> fetchExpenseCategories() async {
    try {
      final envelope = await _apiClient.get(
        '/gastos/categorias',
        requiresAuth: true,
      );

      final items = _asMapList(
        envelope.data,
      ).map(ExpenseCategory.fromMap).toList();
      return AppResult.success(items);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure(
        'No fue posible cargar las categorias de gasto.',
      );
    }
  }

  @override
  Future<AppResult<List<ExpenseRecord>>> fetchExpenses({
    required int vehiculoId,
    int? categoriaId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final envelope = await _apiClient.get(
        '/gastos',
        requiresAuth: true,
        queryParameters: {
          'vehiculo_id': vehiculoId,
          'categoria_id': categoriaId,
          'page': page,
          'limit': limit,
        },
      );

      final items = _asMapList(
        envelope.data,
      ).map(ExpenseRecord.fromMap).toList();
      return AppResult.success(items);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible cargar los gastos.');
    }
  }

  @override
  Future<AppResult<ExpenseRecord>> createExpense({
    required ExpenseInput input,
  }) async {
    try {
      final data = <String, dynamic>{
        'vehiculo_id': input.vehiculoId,
        'categoriaId': input.categoriaId,
        'monto': input.monto,
      };

      if ((input.descripcion ?? '').trim().isNotEmpty) {
        data['descripcion'] = input.descripcion!.trim();
      }

      final envelope = await _apiClient.postDatax(
        '/gastos',
        requiresAuth: true,
        data: data,
      );

      return AppResult.success(ExpenseRecord.fromMap(_asMap(envelope.data)));
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible registrar el gasto.');
    }
  }

  @override
  Future<AppResult<List<IncomeRecord>>> fetchIncomes({
    required int vehiculoId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final envelope = await _apiClient.get(
        '/ingresos',
        requiresAuth: true,
        queryParameters: {
          'vehiculo_id': vehiculoId,
          'page': page,
          'limit': limit,
        },
      );

      final items = _asMapList(
        envelope.data,
      ).map(IncomeRecord.fromMap).toList();
      return AppResult.success(items);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible cargar los ingresos.');
    }
  }

  @override
  Future<AppResult<IncomeRecord>> createIncome({
    required IncomeInput input,
  }) async {
    try {
      final envelope = await _apiClient.postDatax(
        '/ingresos',
        requiresAuth: true,
        data: {
          'vehiculo_id': input.vehiculoId,
          'monto': input.monto,
          'concepto': input.concepto,
        },
      );

      return AppResult.success(IncomeRecord.fromMap(_asMap(envelope.data)));
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible registrar el ingreso.');
    }
  }

  @override
  Future<AppResult<List<PrivateForumTopic>>> fetchForumTopics({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final envelope = await _apiClient.get(
        '/foro/temas',
        requiresAuth: true,
        queryParameters: {'page': page, 'limit': limit},
      );

      final items = _asMapList(
        envelope.data,
      ).map(PrivateForumTopic.fromMap).toList();
      return AppResult.success(items);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible cargar el foro autenticado.');
    }
  }

  @override
  Future<AppResult<PrivateForumDetail>> fetchForumTopicDetail({
    required int id,
  }) async {
    try {
      final envelope = await _apiClient.get(
        '/foro/detalle',
        requiresAuth: true,
        queryParameters: {'id': id},
      );

      return AppResult.success(
        PrivateForumDetail.fromMap(_asMap(envelope.data)),
      );
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible cargar el detalle del tema.');
    }
  }

  @override
  Future<AppResult<PrivateForumTopic>> createForumTopic({
    required int vehiculoId,
    required String titulo,
    required String descripcion,
  }) async {
    try {
      final envelope = await _apiClient.postDatax(
        '/foro/crear',
        requiresAuth: true,
        data: {
          'vehiculo_id': vehiculoId,
          'titulo': titulo,
          'descripcion': descripcion,
        },
      );

      return AppResult.success(
        PrivateForumTopic.fromMap(_asMap(envelope.data)),
      );
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible crear el tema.');
    }
  }

  @override
  Future<AppResult<PrivateForumReply>> replyToForumTopic({
    required int temaId,
    required String contenido,
  }) async {
    try {
      final envelope = await _apiClient.postDatax(
        '/foro/responder',
        requiresAuth: true,
        data: {'tema_id': temaId, 'contenido': contenido},
      );

      return AppResult.success(
        PrivateForumReply.fromMap(_asMap(envelope.data)),
      );
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible publicar la respuesta.');
    }
  }

  @override
  Future<AppResult<List<PrivateForumTopic>>> fetchMyForumTopics({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final envelope = await _apiClient.get(
        '/foro/mis-temas',
        requiresAuth: true,
        queryParameters: {'page': page, 'limit': limit},
      );

      final items = _asMapList(
        envelope.data,
      ).map(PrivateForumTopic.fromMap).toList();
      return AppResult.success(items);
    } on AppException catch (error) {
      return AppResult.failure(error.message);
    } catch (_) {
      return AppResult.failure('No fue posible cargar tus temas.');
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

  List<MultipartFileItem> _fileList(
    List<String> paths, {
    required String fieldName,
  }) {
    return paths
        .where((path) => path.trim().isNotEmpty)
        .map((path) => MultipartFileItem(fieldName: fieldName, filePath: path))
        .toList();
  }
}
