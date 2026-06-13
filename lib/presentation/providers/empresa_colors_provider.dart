import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/data/models/empresa_colors.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';
import 'package:guardaya_app/services/supabase_service.dart';

/// Carga colores desde la tabla 'empresas' en Supabase directamente.
/// Usa el empresa_id del usuario logueado.
final empresaColorsProvider = FutureProvider<EmpresaColors>((ref) async {
  final authState = ref.watch(authProvider);
  final empresaId = authState.usuario?.empresaId;

  if (empresaId == null || empresaId.isEmpty) {
    log('empresaColorsProvider: No hay empresa_id, usando colores por defecto');
    return const EmpresaColors();
  }

  try {
    log('empresaColorsProvider: Cargando colores para empresa_id=$empresaId');
    final response = await SupabaseService.withTimeout(
      SupabaseService.from('empresas')
          .select('color_primario, color_secundario, color_acento')
          .eq('id', empresaId)
          .single(),
      operation: 'empresaColors',
    );

    log('empresaColorsProvider: Response = $response');
    return EmpresaColors.fromJson(response);
  } catch (e) {
    log('empresaColorsProvider: ERROR - $e');
    return const EmpresaColors();
  }
});

// Provider síncrono que escucha cambios de auth y recarga colores
final empresaColorsSyncProvider = Provider<EmpresaColors>((ref) {
  final authState = ref.watch(authProvider);

  // Cuando el usuario cambia, recargamos los colores
  if (authState.isAuthenticated) {
    final asyncValue = ref.watch(empresaColorsProvider);
    return asyncValue.when(
      data: (colors) => colors,
      loading: () => const EmpresaColors(),
      error: (_, __) => const EmpresaColors(),
    );
  }

  return const EmpresaColors();
});
