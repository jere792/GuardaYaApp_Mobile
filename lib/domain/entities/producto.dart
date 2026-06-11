import 'package:equatable/equatable.dart';

class Producto extends Equatable {
  final String id;
  final String empresaId;
  final String? categoriaId;
  final String nombre;
  final String? descripcion;
  final double precio;
  final bool activo;
  final DateTime createdAt;

  const Producto({
    required this.id,
    required this.empresaId,
    this.categoriaId,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.activo,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, empresaId, categoriaId, nombre, descripcion, precio, activo, createdAt];
}
