import 'package:equatable/equatable.dart';

class Cliente extends Equatable {
  final String id;
  final String empresaId;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? notas;
  final bool activo;
  final DateTime createdAt;

  const Cliente({
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

  Cliente copyWith({
    String? id,
    String? empresaId,
    String? nombre,
    String? telefono,
    String? email,
    String? direccion,
    String? notas,
    bool? activo,
    DateTime? createdAt,
  }) {
    return Cliente(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      notas: notas ?? this.notas,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, empresaId, nombre, telefono, email, direccion, notas, activo, createdAt];
}
