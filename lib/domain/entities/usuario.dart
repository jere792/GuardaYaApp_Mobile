import 'package:equatable/equatable.dart';

class Usuario extends Equatable {
  final String id;
  final String? empresaId;
  final String username;
  final String nombre;
  final String? email;
  final String rolId;
  final bool activo;
  final DateTime createdAt;

  const Usuario({
    required this.id,
    this.empresaId,
    required this.username,
    required this.nombre,
    this.email,
    required this.rolId,
    required this.activo,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, empresaId, username, nombre, email, rolId, activo, createdAt];
}