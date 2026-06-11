import 'package:flutter/material.dart';

class EmpresaColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;

  const EmpresaColors({
    this.primary = const Color(0xFFFF6B00),
    this.secondary = const Color(0xFF2D2D2D),
    this.accent = const Color(0xFF00B4D8),
    this.background = const Color(0xFFF8F9FA),
    this.surface = const Color(0xFFFFFFFF),
  });

  factory EmpresaColors.fromJson(Map<String, dynamic> json) {
    return EmpresaColors(
      primary: _hexToColor(json['color_primario'] ?? '#FF6B00'),
      secondary: _hexToColor(json['color_secundario'] ?? '#2D2D2D'),
      accent: _hexToColor(json['color_acento'] ?? '#00B4D8'),
    );
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
