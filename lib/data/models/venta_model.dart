import 'package:guardaya_app/domain/entities/venta.dart';

class VentaModel {
  final String id;
  final String empresaId;
  final String usuarioId;
  final String? clienteId;
  final String? codigoYape;
  final double monto;
  final String? clienteNombre;
  final String? clienteTelefono;
  final DateTime? fechaYape;
  final String? descripcion;
  final String estado;
  final String? imagenYapeUrl;
  final String? imagenEntregaUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VentaModel({
    required this.id,
    required this.empresaId,
    required this.usuarioId,
    this.clienteId,
    this.codigoYape,
    required this.monto,
    this.clienteNombre,
    this.clienteTelefono,
    this.fechaYape,
    this.descripcion,
    required this.estado,
    this.imagenYapeUrl,
    this.imagenEntregaUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory VentaModel.fromJson(Map<String, dynamic> json) {
    return VentaModel(
      id: json['id'] ?? '',
      empresaId: json['empresa_id'] ?? '',
      usuarioId: json['usuario_id'] ?? '',
      clienteId: json['cliente_id'],
      codigoYape: json['codigo_yape'],
      monto: (json['monto'] ?? 0).toDouble(),
      clienteNombre: json['cliente_nombre'],
      clienteTelefono: json['cliente_telefono'],
      fechaYape: json['fecha_yape'] != null ? DateTime.parse(json['fecha_yape']) : null,
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'pendiente',
      imagenYapeUrl: json['imagen_yape_url'],
      imagenEntregaUrl: json['imagen_entrega_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'usuario_id': usuarioId,
      'cliente_id': clienteId,
      'codigo_yape': codigoYape,
      'monto': monto,
      'cliente_nombre': clienteNombre,
      'cliente_telefono': clienteTelefono,
      'fecha_yape': fechaYape?.toIso8601String(),
      'descripcion': descripcion,
      'estado': estado,
      'imagen_yape_url': imagenYapeUrl,
      'imagen_entrega_url': imagenEntregaUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Venta toEntity() => Venta(
    id: id,
    empresaId: empresaId,
    usuarioId: usuarioId,
    clienteId: clienteId,
    codigoYape: codigoYape,
    monto: monto,
    clienteNombre: clienteNombre,
    clienteTelefono: clienteTelefono,
    fechaYape: fechaYape,
    descripcion: descripcion,
    estado: estado,
    imagenYapeUrl: imagenYapeUrl,
    imagenEntregaUrl: imagenEntregaUrl,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory VentaModel.fromEntity(Venta entity) => VentaModel(
    id: entity.id,
    empresaId: entity.empresaId,
    usuarioId: entity.usuarioId,
    clienteId: entity.clienteId,
    codigoYape: entity.codigoYape,
    monto: entity.monto,
    clienteNombre: entity.clienteNombre,
    clienteTelefono: entity.clienteTelefono,
    fechaYape: entity.fechaYape,
    descripcion: entity.descripcion,
    estado: entity.estado,
    imagenYapeUrl: entity.imagenYapeUrl,
    imagenEntregaUrl: entity.imagenEntregaUrl,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}
