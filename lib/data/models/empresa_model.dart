import 'package:guardaya_app/domain/entities/empresa.dart';

class EmpresaModel {
  final String id;
  final String nombre;
  final String slug;
  final String? emailContacto;
  final String? telefono;
  final String? direccion;
  final String? rucDni;
  final String colorPrimario;
  final String colorSecundario;
  final String colorAcento;
  final String? logoUrl;
  final String plan;
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
    this.colorPrimario = '#000000',
    this.colorSecundario = '#FFFFFF',
    this.colorAcento = '#0000FF',
    this.logoUrl,
    this.plan = 'basico',
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
      colorPrimario: json['color_primario'] ?? '#000000',
      colorSecundario: json['color_secundario'] ?? '#FFFFFF',
      colorAcento: json['color_acento'] ?? '#0000FF',
      logoUrl: json['logo_url'],
      plan: json['plan'] ?? 'basico',
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
    colorPrimario: colorPrimario,
    colorSecundario: colorSecundario,
    colorAcento: colorAcento,
    logoUrl: logoUrl,
    plan: plan,
    activo: activo,
    createdAt: createdAt,
  );
}
