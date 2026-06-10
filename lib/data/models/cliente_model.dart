import 'package:guardaya_app/domain/entities/cliente.dart';

class ClienteModel {
  final String id;
  final String empresaId;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? notas;
  final bool activo;
  final DateTime createdAt;

  ClienteModel({
    required this.id,
    required this.empresaId,
    required this.nombre,
    this.telefono,
    this.email,
    this.direccion,
    this.notas,
    required this.activo,
    required this.createdAt,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'] ?? '',
      empresaId: json['empresa_id'] ?? '',
      nombre: json['nombre'] ?? '',
      telefono: json['telefono'],
      email: json['email'],
      direccion: json['direccion'],
      notas: json['notas'],
      activo: json['activo'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'nombre': nombre,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'notas': notas,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Cliente toEntity() => Cliente(
    id: id,
    empresaId: empresaId,
    nombre: nombre,
    telefono: telefono,
    email: email,
    direccion: direccion,
    notas: notas,
    activo: activo,
    createdAt: createdAt,
  );
}