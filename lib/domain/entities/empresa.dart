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

  Empresa copyWith({
    String? id,
    String? nombre,
    String? slug,
    String? emailContacto,
    String? telefono,
    String? direccion,
    String? rucDni,
    String? logoUrl,
    String? plan,
    bool? activo,
    DateTime? createdAt,
  }) {
    return Empresa(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      slug: slug ?? this.slug,
      emailContacto: emailContacto ?? this.emailContacto,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      rucDni: rucDni ?? this.rucDni,
      logoUrl: logoUrl ?? this.logoUrl,
      plan: plan ?? this.plan,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id, nombre, slug, emailContacto, telefono, direccion, rucDni,
    logoUrl, plan, activo, createdAt,
  ];
}
