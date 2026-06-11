import 'package:equatable/equatable.dart';

class Venta extends Equatable {
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

  const Venta({
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

  @override
  List<Object?> get props => [
    id, empresaId, usuarioId, clienteId, codigoYape, monto,
    clienteNombre, clienteTelefono, fechaYape, descripcion, estado,
    imagenYapeUrl, imagenEntregaUrl, createdAt, updatedAt,
  ];
}
