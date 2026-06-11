import 'package:guardaya_app/domain/entities/producto.dart';

class ProductoModel {
  final String id;
  final String empresaId;
  final String? categoriaId;
  final String nombre;
  final String? descripcion;
  final double precio;
  final bool activo;
  final DateTime createdAt;

  ProductoModel({
    required this.id,
    required this.empresaId,
    this.categoriaId,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.activo,
    required this.createdAt,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'] ?? '',
      empresaId: json['empresa_id'] ?? '',
      categoriaId: json['categoria_id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precio: (json['precio'] ?? 0).toDouble(),
      activo: json['activo'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Producto toEntity() => Producto(
    id: id,
    empresaId: empresaId,
    categoriaId: categoriaId,
    nombre: nombre,
    descripcion: descripcion,
    precio: precio,
    activo: activo,
    createdAt: createdAt,
  );
}
