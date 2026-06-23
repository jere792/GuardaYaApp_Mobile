class TipoTransferencia {
  final String id;
  final String nombre;
  final String? icono;
  final String? color;
  final bool activo;

  const TipoTransferencia({
    required this.id,
    required this.nombre,
    this.icono,
    this.color,
    this.activo = true,
  });

  factory TipoTransferencia.fromJson(Map<String, dynamic> json) {
    return TipoTransferencia(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      icono: json['icono'],
      color: json['color'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'icono': icono,
      'color': color,
      'activo': activo,
    };
  }
}
