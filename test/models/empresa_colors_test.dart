import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardaya_app/data/models/empresa_colors.dart';

void main() {
  group('EmpresaColors', () {
    test('fromJson parsea colores válidos correctamente', () {
      final json = {
        'color_primario': '#FF0000',
        'color_secundario': '#00FF00',
        'color_acento': '#0000FF',
      };
      final colors = EmpresaColors.fromJson(json);
      expect(colors.primary, const Color(0xFFFF0000));
      expect(colors.secondary, const Color(0xFF00FF00));
      expect(colors.accent, const Color(0xFF0000FF));
    });

    test('fromJson usa defaults cuando faltan campos', () {
      final colors = EmpresaColors.fromJson({});
      expect(colors.primary, const Color(0xFFFF6B00));
      expect(colors.secondary, const Color(0xFF2D2D2D));
      expect(colors.accent, const Color(0xFF00B4D8));
    });

    test('fromJson no crashea con colores inválidos', () {
      final json = {
        'color_primario': 'not-a-color',
        'color_secundario': '#GGGGGG',
      };
      final colors = EmpresaColors.fromJson(json);
      expect(colors.primary, const Color(0xFFFF6B00)); // fallback inválido
      expect(colors.secondary, const Color(0xFFFF6B00)); // fallback inválido
      expect(colors.accent, const Color(0xFF00B4D8)); // default
    });

    test('fromJson no crashea con null', () {
      final colors = EmpresaColors.fromJson({
        'color_primario': null,
        'color_secundario': null,
      });
      expect(colors.primary, const Color(0xFFFF6B00));
      expect(colors.secondary, const Color(0xFF2D2D2D));
    });
  });
}
