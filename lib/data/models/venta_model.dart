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
  final String? productos;
  final String estado;
  final String? imagenYapeUrl;
  final String? imagenEntregaUrl;
  final String? tipoTransferenciaId;
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
    this.productos,
    required this.estado,
    this.imagenYapeUrl,
    this.imagenEntregaUrl,
    this.tipoTransferenciaId,
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
      productos: json['productos'],
      estado: json['estado'] ?? 'pendiente',
      imagenYapeUrl: json['imagen_yape_url'],
      imagenEntregaUrl: json['imagen_entrega_url'],
      tipoTransferenciaId: json['tipo_transferencia_id'],
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
      'tipo_transferencia_id': tipoTransferenciaId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (clienteId != null) 'cliente_id': clienteId,
      if (codigoYape != null) 'codigo_yape': codigoYape,
      'monto': monto,
      if (clienteNombre != null) 'cliente_nombre': clienteNombre,
      if (clienteTelefono != null) 'cliente_telefono': clienteTelefono,
      if (fechaYape != null) 'fecha_yape': fechaYape?.toIso8601String(),
      if (descripcion != null) 'descripcion': descripcion,
      if (tipoTransferenciaId != null) 'tipo_transferencia_id': tipoTransferenciaId,
      'updated_at': DateTime.now().toIso8601String(),
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
    tipoTransferenciaId: tipoTransferenciaId,
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
    productos: entity.productos,
    estado: entity.estado,
    imagenYapeUrl: entity.imagenYapeUrl,
    imagenEntregaUrl: entity.imagenEntregaUrl,
    tipoTransferenciaId: entity.tipoTransferenciaId,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}
