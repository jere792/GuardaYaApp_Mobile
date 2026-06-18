import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/services/supabase_service.dart';
import 'package:guardaya_app/domain/entities/empresa.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/data/models/empresa_model.dart';
import 'package:guardaya_app/data/models/usuario_model.dart';

class DashboardState {
  final int totalEmpresas;
  final int totalUsuarios;
  final int usuariosActivos;
  final int empresasEsteMes;
  final List<Empresa> ultimasEmpresas;
  final List<Usuario> ultimosUsuarios;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.totalEmpresas = 0,
    this.totalUsuarios = 0,
    this.usuariosActivos = 0,
    this.empresasEsteMes = 0,
    this.ultimasEmpresas = const [],
    this.ultimosUsuarios = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    int? totalEmpresas,
    int? totalUsuarios,
    int? usuariosActivos,
    int? empresasEsteMes,
    List<Empresa>? ultimasEmpresas,
    List<Usuario>? ultimosUsuarios,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      totalEmpresas: totalEmpresas ?? this.totalEmpresas,
      totalUsuarios: totalUsuarios ?? this.totalUsuarios,
      usuariosActivos: usuariosActivos ?? this.usuariosActivos,
      empresasEsteMes: empresasEsteMes ?? this.empresasEsteMes,
      ultimasEmpresas: ultimasEmpresas ?? this.ultimasEmpresas,
      ultimosUsuarios: ultimosUsuarios ?? this.ultimosUsuarios,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());

  Future<void> cargarDatos() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final empresasData = await SupabaseService.from('empresas')
          .select()
          .order('created_at', ascending: false);

      final usuariosData = await SupabaseService.from('usuarios')
          .select()
          .order('created_at', ascending: false);

      final empresasList = (empresasData as List).map((e) =>
          EmpresaModel.fromJson(e as Map<String, dynamic>).toEntity()).toList();
      final usuariosList = (usuariosData as List).map((u) =>
          UsuarioModel.fromJson(u as Map<String, dynamic>).toEntity()).toList();

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final empresasEsteMes = empresasList
          .where((e) => e.createdAt.isAfter(startOfMonth.subtract(const Duration(days: 1))))
          .length;
      final usuariosActivos = usuariosList.where((u) => u.activo).length;

      state = state.copyWith(
        totalEmpresas: empresasList.length,
        totalUsuarios: usuariosList.length,
        usuariosActivos: usuariosActivos,
        empresasEsteMes: empresasEsteMes,
        ultimasEmpresas: empresasList.take(5).toList(),
        ultimosUsuarios: usuariosList.take(5).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
