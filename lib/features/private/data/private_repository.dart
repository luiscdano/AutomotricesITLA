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
}
