class AppUser {
  const AppUser({
    required this.id,
    this.matricula,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.fotoUrl,
    this.rol,
    this.grupo,
  });

  final int id;
  final String? matricula;
  final String nombre;
  final String apellido;
  final String correo;
  final String? fotoUrl;
  final String? rol;
  final String? grupo;

  String get displayName {
    final fullName = '$nombre $apellido'.trim();
    return fullName.isEmpty ? correo : fullName;
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: _toInt(map['id']),
      matricula: map['matricula']?.toString(),
      nombre: map['nombre']?.toString() ?? '',
      apellido: map['apellido']?.toString() ?? '',
      correo: map['correo']?.toString() ?? '',
      fotoUrl: map['fotoUrl']?.toString(),
      rol: map['rol']?.toString(),
      grupo: map['grupo']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matricula': matricula,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'fotoUrl': fotoUrl,
      'rol': rol,
      'grupo': grupo,
    };
  }

  AppUser copyWith({
    int? id,
    String? matricula,
    String? nombre,
    String? apellido,
    String? correo,
    String? fotoUrl,
    String? rol,
    String? grupo,
  }) {
    return AppUser(
      id: id ?? this.id,
      matricula: matricula ?? this.matricula,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      rol: rol ?? this.rol,
      grupo: grupo ?? this.grupo,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
