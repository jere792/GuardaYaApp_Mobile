import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/data/datasources/remote/empresas_datasource.dart';
import 'package:guardaya_app/data/repositories/implementations/empresas_repository_impl.dart';
import 'package:guardaya_app/domain/entities/empresa.dart';
import 'package:guardaya_app/domain/usecases/empresas/actualizar_empresa.dart';
import 'package:guardaya_app/domain/usecases/empresas/crear_empresa.dart';
import 'package:guardaya_app/domain/usecases/empresas/desactivar_empresa.dart';
import 'package:guardaya_app/domain/usecases/empresas/listar_empresas.dart';
import 'package:guardaya_app/services/supabase_service.dart';

final empresasDatasourceProvider = Provider<EmpresasDatasource>((ref) => EmpresasDatasource());
final empresasRepositoryProvider = Provider((ref) => EmpresasRepositoryImpl(ref.watch(empresasDatasourceProvider)));
final listarEmpresasProvider = Provider<ListarEmpresas>((ref) => ListarEmpresas(ref.watch(empresasRepositoryProvider)));
final crearEmpresaProvider = Provider<CrearEmpresa>((ref) => CrearEmpresa(ref.watch(empresasRepositoryProvider)));
final actualizarEmpresaProvider = Provider<ActualizarEmpresa>((ref) => ActualizarEmpresa(ref.watch(empresasRepositoryProvider)));
final desactivarEmpresaProvider = Provider<DesactivarEmpresa>((ref) => DesactivarEmpresa(ref.watch(empresasRepositoryProvider)));

final empresasProvider = StateNotifierProvider<EmpresasNotifier, EmpresasState>((ref) {
  return EmpresasNotifier(
    listar: ref.watch(listarEmpresasProvider),
    crear: ref.watch(crearEmpresaProvider),
    actualizar: ref.watch(actualizarEmpresaProvider),
    desactivar: ref.watch(desactivarEmpresaProvider),
  );
});

class EmpresaSimple {
  final String id;
  final String nombre;
  EmpresaSimple({required this.id, required this.nombre});
}

final empresasActivasProvider = FutureProvider<List<EmpresaSimple>>((ref) async {
  final data = await SupabaseService.from('empresas')
      .select('id, nombre')
      .eq('activo', true)
      .order('nombre', ascending: true)
      .timeout(const Duration(seconds: 15));

  return (data as List).map((e) => EmpresaSimple(
    id: e['id'] as String,
    nombre: e['nombre'] as String,
  )).toList();
});

class EmpresasState {
  final List<Empresa> empresas;
  final bool isLoading;
  final String? error;
  final bool success;

  const EmpresasState({
    this.empresas = const [],
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  EmpresasState copyWith({
    List<Empresa>? empresas,
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return EmpresasState(
      empresas: empresas ?? this.empresas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class EmpresasNotifier extends StateNotifier<EmpresasState> {
  final ListarEmpresas _listar;
  final CrearEmpresa _crear;
  final ActualizarEmpresa _actualizar;
  final DesactivarEmpresa _desactivar;

  EmpresasNotifier({
    required ListarEmpresas listar,
    required CrearEmpresa crear,
    required ActualizarEmpresa actualizar,
    required DesactivarEmpresa desactivar,
  })  : _listar = listar,
        _crear = crear,
        _actualizar = actualizar,
        _desactivar = desactivar,
        super(const EmpresasState());

  Future<void> cargarEmpresas() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _listar(const NoParams());
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (empresas) => state = state.copyWith(isLoading: false, empresas: empresas),
    );
  }

  Future<void> crearEmpresa(Empresa empresa) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _crear(CrearEmpresaParams(empresa: empresa));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (empresa) {
        state = state.copyWith(
          isLoading: false,
          empresas: [empresa, ...state.empresas],
          success: true,
        );
      },
    );
  }

  Future<void> actualizarEmpresa(Empresa empresa) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _actualizar(ActualizarEmpresaParams(empresa: empresa));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (empresa) {
        final updated = state.empresas.map((e) => e.id == empresa.id ? empresa : e).toList();
        state = state.copyWith(isLoading: false, empresas: updated, success: true);
      },
    );
  }

  Future<void> desactivarEmpresa(String empresaId, {bool reactivar = false}) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _desactivar(DesactivarEmpresaParams(empresaId: empresaId, reactivar: reactivar));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        final updated = state.empresas.map((e) {
          if (e.id == empresaId) return e.copyWith(activo: reactivar);
          return e;
        }).toList();
        state = state.copyWith(isLoading: false, empresas: updated, success: true);
      },
    );
  }

  void resetSuccess() {
    state = state.copyWith(success: false);
  }

  void resetError() {
    state = state.copyWith(error: null);
  }
}
