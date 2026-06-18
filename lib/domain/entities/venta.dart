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
  final String? productos;
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
    this.productos,
    required this.estado,
    this.imagenYapeUrl,
    this.imagenEntregaUrl,
    required this.createdAt,
    this.updatedAt,
  });

  Venta copyWith({
    String? id,
    String? empresaId,
    String? usuarioId,
    String? clienteId,
    String? codigoYape,
    double? monto,
    String? clienteNombre,
    String? clienteTelefono,
    DateTime? fechaYape,
    String? descripcion,
    String? productos,
    String? estado,
    String? imagenYapeUrl,
    String? imagenEntregaUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Venta(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      usuarioId: usuarioId ?? this.usuarioId,
      clienteId: clienteId ?? this.clienteId,
      codigoYape: codigoYape ?? this.codigoYape,
      monto: monto ?? this.monto,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clienteTelefono: clienteTelefono ?? this.clienteTelefono,
      fechaYape: fechaYape ?? this.fechaYape,
      descripcion: descripcion ?? this.descripcion,
      productos: productos ?? this.productos,
      estado: estado ?? this.estado,
      imagenYapeUrl: imagenYapeUrl ?? this.imagenYapeUrl,
      imagenEntregaUrl: imagenEntregaUrl ?? this.imagenEntregaUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, empresaId, usuarioId, clienteId, codigoYape, monto,
    clienteNombre, clienteTelefono, fechaYape, descripcion, productos, estado,
    imagenYapeUrl, imagenEntregaUrl, createdAt, updatedAt,
  ];
}
