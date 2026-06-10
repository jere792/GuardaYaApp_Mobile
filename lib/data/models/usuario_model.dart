import 'package:guardaya_app/domain/entities/usuario.dart';

class UsuarioModel {
  final String id;
  final String? empresaId;
  final String username;
  final String nombre;
  final String? email;
  final String rolId;
  final bool activo;
  final DateTime createdAt;

  UsuarioModel({
    required this.id,
    this.empresaId,
    required this.username,
    required this.nombre,
    this.email,
    required this.rolId,
    required this.activo,
    required this.createdAt,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] ?? '',
      empresaId: json['empresa_id'],
      username: json['username'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'],
      rolId: json['rol_id'] ?? '',
      activo: json['activo'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'username': username,
      'nombre': nombre,
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
    email: email,
    rolId: rolId,
    activo: activo,
    createdAt: createdAt,
  );
}