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

  Producto copyWith({
    String? id,
    String? empresaId,
    String? categoriaId,
    String? nombre,
    String? descripcion,
    double? precio,
    bool? activo,
    DateTime? createdAt,
  }) {
    return Producto(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      categoriaId: categoriaId ?? this.categoriaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, empresaId, categoriaId, nombre, descripcion, precio, activo, createdAt];
}
