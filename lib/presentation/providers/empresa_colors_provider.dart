import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/data/models/empresa_colors.dart';
import 'package:guardaya_app/presentation/providers/auth_provider.dart';

final empresaColorsProvider = FutureProvider<EmpresaColors>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final result = await authRepo.getEmpresaColors();
  return result.fold(
    (failure) => const EmpresaColors(),
    (colors) => colors,
  );
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
