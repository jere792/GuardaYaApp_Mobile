import 'package:guardaya_app/domain/entities/usuario.dart';

class UsuarioModel {
  final String id;
  final String? empresaId;
  final String username;
  final String nombre;
  final String? apellidos;
  final String? telefono;
  final String? email;
  final String rolId;
  final bool activo;
  final DateTime createdAt;

  UsuarioModel({
    required this.id,
    this.empresaId,
    required this.username,
    required this.nombre,
    this.apellidos,
    this.telefono,
    this.email,
    required this.rolId,
    required this.activo,
    required this.createdAt,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    DateTime parseCreatedAt(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    bool parseActivo(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return true;
    }

    return UsuarioModel(
      id: json['id']?.toString() ?? '',
      empresaId: json['empresa_id']?.toString(),
      username: json['username']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellidos: json['apellidos']?.toString(),
      telefono: json['telefono']?.toString(),
      email: json['email']?.toString(),
      rolId: json['rol_id']?.toString() ?? json['rol_nombre']?.toString() ?? '',
      activo: parseActivo(json['activo']),
      createdAt: parseCreatedAt(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'username': username,
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
      'email': email,
      'rol_id': rolId,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Usuario toEntity() => Usuario(
    id: id,
    empresaId: empresaId,
    username: username,
    nombre: nombre,
    apellidos: apellidos,
    telefono: telefono,
    email: email,
    rolId: rolId,
    activo: activo,
    createdAt: createdAt,
  );
}
