import 'package:equatable/equatable.dart';

class Empresa extends Equatable {
  final String id;
  final String nombre;
  final String slug;
  final String? emailContacto;
  final String? telefono;
  final String? direccion;
  final String? rucDni;
  final String? logoUrl;
  final String plan;
  final bool activo;
  final DateTime createdAt;

  const Empresa({
    required this.id,
    required this.nombre,
    required this.slug,
    this.emailContacto,
    this.telefono,
    this.direccion,
    this.rucDni,
    this.logoUrl,
    this.plan = 'basico',
    required this.activo,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, nombre, slug, emailContacto, telefono, direccion, rucDni,
    logoUrl, plan, activo, createdAt,
  ];
}
