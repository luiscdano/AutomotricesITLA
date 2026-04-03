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

class MaintenanceRecord {
  const MaintenanceRecord({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.costo,
    required this.piezas,
    required this.fecha,
    required this.fotos,
  });

  final int id;
  final int vehiculoId;
  final String tipo;
  final double costo;
  final String piezas;
  final String fecha;
  final List<String> fotos;

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecord(
      id: _toInt(_read(map, ['id'])),
      vehiculoId: _toInt(_read(map, ['vehiculo_id', 'vehiculoId'])),
      tipo: _toStr(_read(map, ['tipo'])),
      costo: _toDouble(_read(map, ['costo'])),
      piezas: _toStr(_read(map, ['piezas'])),
      fecha: _toStr(_read(map, ['fecha'])),
      fotos: _toStringList(_read(map, ['fotos'])),
    );
  }
}

class FuelRecord {
  const FuelRecord({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.cantidad,
    required this.unidad,
    required this.monto,
    required this.fecha,
  });

  final int id;
  final int vehiculoId;
  final String tipo;
  final double cantidad;
  final String unidad;
  final double monto;
  final String fecha;

  factory FuelRecord.fromMap(Map<String, dynamic> map) {
    return FuelRecord(
      id: _toInt(_read(map, ['id'])),
      vehiculoId: _toInt(_read(map, ['vehiculo_id', 'vehiculoId'])),
      tipo: _toStr(_read(map, ['tipo'])),
      cantidad: _toDouble(_read(map, ['cantidad'])),
      unidad: _toStr(_read(map, ['unidad'])),
      monto: _toDouble(_read(map, ['monto'])),
      fecha: _toStr(_read(map, ['fecha'])),
    );
  }
}

class TireStatus {
  const TireStatus({
    required this.id,
    required this.vehiculoId,
    required this.posicion,
    required this.eje,
    required this.estado,
    required this.totalPinchazos,
  });

  final int id;
  final int vehiculoId;
  final String posicion;
  final int eje;
  final String estado;
  final int totalPinchazos;

  factory TireStatus.fromMap(Map<String, dynamic> map) {
    return TireStatus(
      id: _toInt(_read(map, ['id'])),
      vehiculoId: _toInt(_read(map, ['vehiculo_id', 'vehiculoId'])),
      posicion: _toStr(_read(map, ['posicion'])),
      eje: _toInt(_read(map, ['eje'])),
      estado: _toStr(_read(map, ['estado'])),
      totalPinchazos: _toInt(_read(map, ['totalPinchazos'])),
    );
  }
}

class TireState {
  const TireState({required this.cantidadRuedas, required this.gomas});

  final int cantidadRuedas;
  final List<TireStatus> gomas;

  factory TireState.fromMap(Map<String, dynamic> map) {
    final tires = _asMapList(_read(map, ['gomas'])).map(TireStatus.fromMap);

    return TireState(
      cantidadRuedas: _toInt(_read(map, ['cantidadRuedas', 'cantidad_ruedas'])),
      gomas: tires.toList(),
    );
  }
}

class TirePuncture {
  const TirePuncture({
    required this.id,
    required this.gomaId,
    required this.descripcion,
    required this.fecha,
  });

  final int id;
  final int gomaId;
  final String descripcion;
  final String fecha;

  factory TirePuncture.fromMap(Map<String, dynamic> map) {
    return TirePuncture(
      id: _toInt(_read(map, ['id'])),
      gomaId: _toInt(_read(map, ['gomaId', 'goma_id'])),
      descripcion: _toStr(_read(map, ['descripcion'])),
      fecha: _toStr(_read(map, ['fecha'])),
    );
  }
}

class ExpenseCategory {
  const ExpenseCategory({required this.id, required this.nombre});

  final int id;
  final String nombre;

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: _toInt(_read(map, ['id'])),
      nombre: _toStr(_read(map, ['nombre'])),
    );
  }
}

class ExpenseRecord {
  const ExpenseRecord({
    required this.id,
    required this.vehiculoId,
    required this.categoriaId,
    required this.categoriaNombre,
    required this.monto,
    required this.descripcion,
    required this.fecha,
  });

  final int id;
  final int vehiculoId;
  final int categoriaId;
  final String categoriaNombre;
  final double monto;
  final String descripcion;
  final String fecha;

  factory ExpenseRecord.fromMap(Map<String, dynamic> map) {
    return ExpenseRecord(
      id: _toInt(_read(map, ['id'])),
      vehiculoId: _toInt(_read(map, ['vehiculo_id', 'vehiculoId'])),
      categoriaId: _toInt(_read(map, ['categoria_id', 'categoriaId'])),
      categoriaNombre: _toStr(_read(map, ['categoriaNombre'])),
      monto: _toDouble(_read(map, ['monto'])),
      descripcion: _toStr(_read(map, ['descripcion'])),
      fecha: _toStr(_read(map, ['fecha'])),
    );
  }
}

class IncomeRecord {
  const IncomeRecord({
    required this.id,
    required this.vehiculoId,
    required this.monto,
    required this.concepto,
    required this.fecha,
  });

  final int id;
  final int vehiculoId;
  final double monto;
  final String concepto;
  final String fecha;

  factory IncomeRecord.fromMap(Map<String, dynamic> map) {
    return IncomeRecord(
      id: _toInt(_read(map, ['id'])),
      vehiculoId: _toInt(_read(map, ['vehiculo_id', 'vehiculoId'])),
      monto: _toDouble(_read(map, ['monto'])),
      concepto: _toStr(_read(map, ['concepto'])),
      fecha: _toStr(_read(map, ['fecha'])),
    );
  }
}

class PrivateForumTopic {
  const PrivateForumTopic({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.vehiculo,
    required this.vehiculoFoto,
    required this.autor,
    required this.totalRespuestas,
    required this.ultimaRespuesta,
  });

  final int id;
  final String titulo;
  final String descripcion;
  final String fecha;
  final String vehiculo;
  final String vehiculoFoto;
  final String autor;
  final int totalRespuestas;
  final String ultimaRespuesta;

  factory PrivateForumTopic.fromMap(Map<String, dynamic> map) {
    return PrivateForumTopic(
      id: _toInt(_read(map, ['id'])),
      titulo: _toStr(_read(map, ['titulo'])),
      descripcion: _toStr(_read(map, ['descripcion'])),
      fecha: _toStr(_read(map, ['fecha'])),
      vehiculo: _toStr(_read(map, ['vehiculo'])),
      vehiculoFoto: _toStr(_read(map, ['vehiculoFoto', 'vehiculo_foto'])),
      autor: _toStr(_read(map, ['autor'])),
      totalRespuestas: _toInt(_read(map, ['totalRespuestas'])),
      ultimaRespuesta: _toStr(_read(map, ['ultimaRespuesta'])),
    );
  }
}

class PrivateForumReply {
  const PrivateForumReply({
    required this.id,
    required this.temaId,
    required this.contenido,
    required this.autor,
    required this.fecha,
    required this.autorFotoUrl,
  });

  final int id;
  final int temaId;
  final String contenido;
  final String autor;
  final String fecha;
  final String autorFotoUrl;

  factory PrivateForumReply.fromMap(Map<String, dynamic> map) {
    return PrivateForumReply(
      id: _toInt(_read(map, ['id'])),
      temaId: _toInt(_read(map, ['tema_id', 'temaId'])),
      contenido: _toStr(_read(map, ['contenido'])),
      autor: _toStr(_read(map, ['autor'])),
      fecha: _toStr(_read(map, ['fecha'])),
      autorFotoUrl: _toStr(_read(map, ['autorFotoUrl', 'autor_foto_url'])),
    );
  }
}

class PrivateForumDetail {
  const PrivateForumDetail({required this.topic, required this.replies});

  final PrivateForumTopic topic;
  final List<PrivateForumReply> replies;

  factory PrivateForumDetail.fromMap(Map<String, dynamic> map) {
    return PrivateForumDetail(
      topic: PrivateForumTopic.fromMap(map),
      replies: _asMapList(
        _read(map, ['respuestas']),
      ).map(PrivateForumReply.fromMap).toList(),
    );
  }
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

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => item.map((key, val) => MapEntry(key.toString(), val)))
      .toList();
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

List<String> _toStringList(dynamic value) {
  if (value is! List) return <String>[];
  return value.map((item) => item.toString()).toList();
}
