import 'package:equatable/equatable.dart';

class Categoria extends Equatable {
  final String id;
  final String? empresaId;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final DateTime createdAt;

  const Categoria({
    required this.id,
    this.empresaId,
    required this.nombre,
    this.descripcion,
    this.activo = true,
    required this.createdAt,
  });

  Categoria copyWith({
    String? id,
    String? empresaId,
    String? nombre,
    String? descripcion,
    bool? activo,
    DateTime? createdAt,
  }) {
    return Categoria(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, empresaId, nombre, descripcion, activo, createdAt];
}