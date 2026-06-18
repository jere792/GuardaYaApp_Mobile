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

    return ProductoModel(
      id: json['id']?.toString() ?? '',
      empresaId: json['empresa_id']?.toString() ?? '',
      categoriaId: json['categoria_id']?.toString(),
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      precio: (json['precio'] ?? 0).toDouble(),
      activo: parseActivo(json['activo']),
      createdAt: parseCreatedAt(json['created_at']),
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

  Map<String, dynamic> toInsertJson() {
    return {
      'empresa_id': empresaId,
      'categoria_id': categoriaId,
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'precio': precio,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'precio': precio,
      'categoria_id': categoriaId,
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
