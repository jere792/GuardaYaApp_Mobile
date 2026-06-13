import 'package:equatable/equatable.dart';

class Usuario extends Equatable {
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

  const Usuario({
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

  @override
  List<Object?> get props => [id, empresaId, username, nombre, apellidos, telefono, email, rolId, activo, createdAt];
}
