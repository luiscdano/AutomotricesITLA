import '../../../core/result/app_result.dart';
import '../models/private_models.dart';

class VehicleInput {
  const VehicleInput({
    required this.placa,
    required this.chasis,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.cantidadRuedas,
  });

  final String placa;
  final String chasis;
  final String marca;
  final String modelo;
  final int anio;
  final int cantidadRuedas;
}

class MaintenanceInput {
  const MaintenanceInput({
    required this.vehiculoId,
    required this.tipo,
    required this.costo,
    this.piezas,
    this.fecha,
  });

  final int vehiculoId;
  final String tipo;
  final double costo;
  final String? piezas;
  final String? fecha;
}

class FuelInput {
  const FuelInput({
    required this.vehiculoId,
    required this.tipo,
    required this.cantidad,
    required this.unidad,
    required this.monto,
  });

  final int vehiculoId;
  final String tipo;
  final double cantidad;
  final String unidad;
  final double monto;
}

class ExpenseInput {
  const ExpenseInput({
    required this.vehiculoId,
    required this.categoriaId,
    required this.monto,
    this.descripcion,
  });

  final int vehiculoId;
  final int categoriaId;
  final double monto;
  final String? descripcion;
}

class IncomeInput {
  const IncomeInput({
    required this.vehiculoId,
    required this.monto,
    required this.concepto,
  });

  final int vehiculoId;
  final double monto;
  final String concepto;
}

abstract class PrivateRepository {
  Future<AppResult<UserProfile>> fetchProfile();

  Future<AppResult<String>> uploadProfilePhoto({required String filePath});

  Future<AppResult<VehiclePage>> fetchVehicles({
    int page = 1,
    int limit = 20,
    String? marca,
    String? modelo,
  });

  Future<AppResult<VehicleItem>> createVehicle({
    required VehicleInput input,
    String? photoPath,
  });

  Future<AppResult<VehicleItem>> updateVehicle({
    required int id,
    required VehicleInput input,
  });

  Future<AppResult<String>> uploadVehiclePhoto({
    required int id,
    required String filePath,
  });

  Future<AppResult<VehicleDetail>> fetchVehicleDetail({required int id});

  Future<AppResult<List<MaintenanceRecord>>> fetchMaintenances({
    required int vehiculoId,
    String? tipo,
    int page = 1,
    int limit = 50,
  });

  Future<AppResult<MaintenanceRecord>> createMaintenance({
    required MaintenanceInput input,
    List<String> photoPaths = const [],
  });

  Future<AppResult<MaintenanceRecord>> fetchMaintenanceDetail({
    required int id,
  });

  Future<AppResult<List<String>>> uploadMaintenancePhotos({
    required int maintenanceId,
    required List<String> photoPaths,
  });

  Future<AppResult<List<FuelRecord>>> fetchFuelRecords({
    required int vehiculoId,
    String? tipo,
    int page = 1,
    int limit = 50,
  });

  Future<AppResult<FuelRecord>> createFuelRecord({required FuelInput input});

  Future<AppResult<TireState>> fetchTireState({required int vehiculoId});

  Future<AppResult<TireStatus>> updateTireStatus({
    required int tireId,
    required String estado,
  });

  Future<AppResult<TirePuncture>> registerTirePuncture({
    required int tireId,
    String? descripcion,
    String? fecha,
  });

  Future<AppResult<List<ExpenseCategory>>> fetchExpenseCategories();

  Future<AppResult<List<ExpenseRecord>>> fetchExpenses({
    required int vehiculoId,
    int? categoriaId,
    int page = 1,
    int limit = 50,
  });

  Future<AppResult<ExpenseRecord>> createExpense({required ExpenseInput input});

  Future<AppResult<List<IncomeRecord>>> fetchIncomes({
    required int vehiculoId,
    int page = 1,
    int limit = 50,
  });

  Future<AppResult<IncomeRecord>> createIncome({required IncomeInput input});

  Future<AppResult<List<PrivateForumTopic>>> fetchForumTopics({
    int page = 1,
    int limit = 50,
  });

  Future<AppResult<PrivateForumDetail>> fetchForumTopicDetail({
    required int id,
  });

  Future<AppResult<PrivateForumTopic>> createForumTopic({
    required int vehiculoId,
    required String titulo,
    required String descripcion,
  });

  Future<AppResult<PrivateForumReply>> replyToForumTopic({
    required int temaId,
    required String contenido,
  });

  Future<AppResult<List<PrivateForumTopic>>> fetchMyForumTopics({
    int page = 1,
    int limit = 50,
  });
}
