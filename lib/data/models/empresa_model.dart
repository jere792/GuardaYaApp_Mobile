import 'package:guardaya_app/domain/entities/empresa.dart';

class EmpresaModel {
  final String id;
  final String nombre;
  final String slug;
  final String? emailContacto;
  final String? telefono;
  final String? direccion;
  final String? rucDni;
  final String? logoUrl;
  final String plan;
  final int limiteUsuarios;
  final bool activo;
  final DateTime createdAt;

  EmpresaModel({
    required this.id,
    required this.nombre,
    required this.slug,
    this.emailContacto,
    this.telefono,
    this.direccion,
    this.rucDni,
    this.logoUrl,
    this.plan = 'basico',
    this.limiteUsuarios = 0,
    required this.activo,
    required this.createdAt,
  });

  factory EmpresaModel.fromJson(Map<String, dynamic> json) {
    return EmpresaModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      slug: json['slug'] ?? '',
      emailContacto: json['email_contacto'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      rucDni: json['ruc_dni'],
      logoUrl: json['logo_url'],
      plan: json['plan'] ?? 'basico',
      limiteUsuarios: json['limite_usuarios'] ?? 0,
      activo: json['activo'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Empresa toEntity() => Empresa(
    id: id,
    nombre: nombre,
    slug: slug,
    emailContacto: emailContacto,
    telefono: telefono,
    direccion: direccion,
    rucDni: rucDni,
    logoUrl: logoUrl,
    plan: plan,
    limiteUsuarios: limiteUsuarios,
    activo: activo,
    createdAt: createdAt,
  );
}
