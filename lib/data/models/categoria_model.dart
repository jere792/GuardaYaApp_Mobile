import 'package:guardaya_app/domain/entities/categoria.dart';

class CategoriaModel {
  final String id;
  final String? empresaId;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final DateTime createdAt;

  CategoriaModel({
    required this.id,
    this.empresaId,
    required this.nombre,
    this.descripcion,
    required this.activo,
    required this.createdAt,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
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

    return CategoriaModel(
      id: json['id']?.toString() ?? '',
      empresaId: json['empresa_id']?.toString(),
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      activo: parseActivo(json['activo']),
      createdAt: parseCreatedAt(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      if (empresaId != null) 'empresa_id': empresaId,
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }

  Categoria toEntity() => Categoria(
    id: id,
    empresaId: empresaId,
    nombre: nombre,
    descripcion: descripcion,
    activo: activo,
    createdAt: createdAt,
  );
}