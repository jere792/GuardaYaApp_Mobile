import 'package:guardaya_app/core/constants/app_constants.dart';

class PendingVentaModel {
  final String id;
  final String empresaId;
  final String usuarioId;
  final String? clienteId;
  final String? codigoYape;
  final double monto;
  final String? clienteNombre;
  final String? clienteTelefono;
  final String? fechaYape;
  final String? descripcion;
  final String estado;
  final String? imagenYapeLocalPath;
  final String? imagenEntregaLocalPath;
  final String createdAt;
  final String syncStatus;
  final String? syncError;
  final int retryCount;

  PendingVentaModel({
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
    this.estado = 'pendiente',
    this.imagenYapeLocalPath,
    this.imagenEntregaLocalPath,
    required this.createdAt,
    this.syncStatus = AppConstants.pendingStatus,
    this.syncError,
    this.retryCount = 0,
  });

  factory PendingVentaModel.fromMap(Map<String, dynamic> map) {
    return PendingVentaModel(
      id: map['id'] ?? '',
      empresaId: map['empresa_id'] ?? '',
      usuarioId: map['usuario_id'] ?? '',
      clienteId: map['cliente_id'],
      codigoYape: map['codigo_yape'],
      monto: (map['monto'] ?? 0).toDouble(),
      clienteNombre: map['cliente_nombre'],
      clienteTelefono: map['cliente_telefono'],
      fechaYape: map['fecha_yape'],
      descripcion: map['descripcion'],
      estado: map['estado'] ?? 'pendiente',
      imagenYapeLocalPath: map['imagen_yape_local_path'],
      imagenEntregaLocalPath: map['imagen_entrega_local_path'],
      createdAt: map['created_at'] ?? DateTime.now().toIso8601String(),
      syncStatus: map['sync_status'] ?? AppConstants.pendingStatus,
      syncError: map['sync_error'],
      retryCount: map['retry_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'usuario_id': usuarioId,
      'cliente_id': clienteId,
      'codigo_yape': codigoYape,
      'monto': monto,
      'cliente_nombre': clienteNombre,
      'cliente_telefono': clienteTelefono,
      'fecha_yape': fechaYape,
      'descripcion': descripcion,
      'estado': estado,
      'imagen_yape_local_path': imagenYapeLocalPath,
      'imagen_entrega_local_path': imagenEntregaLocalPath,
      'created_at': createdAt,
      'sync_status': syncStatus,
      'sync_error': syncError,
      'retry_count': retryCount,
    };
  }
}