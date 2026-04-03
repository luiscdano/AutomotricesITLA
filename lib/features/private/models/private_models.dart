class UserProfile {
  const UserProfile({
    required this.id,
    required this.matricula,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.rol,
    required this.grupo,
    required this.fotoUrl,
    required this.fechaRegistro,
  });

  final int id;
  final String matricula;
  final String nombre;
  final String apellido;
  final String correo;
  final String rol;
  final String grupo;
  final String fotoUrl;
  final String fechaRegistro;

  String get displayName {
    final value = '$nombre $apellido'.trim();
    return value.isEmpty ? correo : value;
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: _toInt(_read(map, ['id'])),
      matricula: _toStr(_read(map, ['matricula'])),
      nombre: _toStr(_read(map, ['nombre'])),
      apellido: _toStr(_read(map, ['apellido'])),
      correo: _toStr(_read(map, ['correo'])),
      rol: _toStr(_read(map, ['rol'])),
      grupo: _toStr(_read(map, ['grupo'])),
      fotoUrl: _toStr(_read(map, ['fotoUrl', 'foto_url'])),
      fechaRegistro: _toStr(_read(map, ['fechaRegistro', 'fecha_registro'])),
    );
  }
}

class VehicleItem {
  const VehicleItem({
    required this.id,
    required this.placa,
    required this.chasis,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.cantidadRuedas,
    required this.fotoUrl,
    required this.fechaRegistro,
  });

  final int id;
  final String placa;
  final String chasis;
  final String marca;
  final String modelo;
  final int anio;
  final int cantidadRuedas;
  final String fotoUrl;
  final String fechaRegistro;

  String get displayName => '$marca $modelo'.trim();

  factory VehicleItem.fromMap(Map<String, dynamic> map) {
    return VehicleItem(
      id: _toInt(_read(map, ['id'])),
      placa: _toStr(_read(map, ['placa'])),
      chasis: _toStr(_read(map, ['chasis'])),
      marca: _toStr(_read(map, ['marca'])),
      modelo: _toStr(_read(map, ['modelo'])),
      anio: _toInt(_read(map, ['anio'])),
      cantidadRuedas: _toInt(_read(map, ['cantidadRuedas', 'cantidad_ruedas'])),
      fotoUrl: _toStr(_read(map, ['fotoUrl', 'foto_url'])),
      fechaRegistro: _toStr(_read(map, ['fechaRegistro', 'fecha_registro'])),
    );
  }
}

class VehicleFinancialSummary {
  const VehicleFinancialSummary({
    required this.totalMantenimientos,
    required this.totalCombustible,
    required this.totalGastos,
    required this.totalIngresos,
    required this.totalInvertido,
    required this.balance,
  });

  final double totalMantenimientos;
  final double totalCombustible;
  final double totalGastos;
  final double totalIngresos;
  final double totalInvertido;
  final double balance;

  factory VehicleFinancialSummary.fromMap(Map<String, dynamic> map) {
    return VehicleFinancialSummary(
      totalMantenimientos: _toDouble(_read(map, ['totalMantenimientos'])),
      totalCombustible: _toDouble(_read(map, ['totalCombustible'])),
      totalGastos: _toDouble(_read(map, ['totalGastos'])),
      totalIngresos: _toDouble(_read(map, ['totalIngresos'])),
      totalInvertido: _toDouble(_read(map, ['totalInvertido'])),
      balance: _toDouble(_read(map, ['balance'])),
    );
  }

  static const empty = VehicleFinancialSummary(
    totalMantenimientos: 0,
    totalCombustible: 0,
    totalGastos: 0,
    totalIngresos: 0,
    totalInvertido: 0,
    balance: 0,
  );
}

class VehicleDetail {
  const VehicleDetail({required this.vehicle, required this.summary});

  final VehicleItem vehicle;
  final VehicleFinancialSummary summary;

  factory VehicleDetail.fromMap(Map<String, dynamic> map) {
    final summaryMap = _asMap(_read(map, ['resumen']));
    return VehicleDetail(
      vehicle: VehicleItem.fromMap(map),
      summary: summaryMap.isEmpty
          ? VehicleFinancialSummary.empty
          : VehicleFinancialSummary.fromMap(summaryMap),
    );
  }
}

class VehiclePage {
  const VehiclePage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<VehicleItem> items;
  final int page;
  final int limit;
  final int total;
}

dynamic _read(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    if (map.containsKey(key) && map[key] != null) {
      return map[key];
    }
  }
  return null;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

String _toStr(dynamic value) => value?.toString() ?? '';

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
