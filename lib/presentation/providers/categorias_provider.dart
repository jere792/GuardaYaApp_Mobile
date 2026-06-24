import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/data/datasources/remote/categorias_datasource.dart';
import 'package:guardaya_app/data/repositories/implementations/categorias_repository_impl.dart';
import 'package:guardaya_app/domain/entities/categoria.dart';
import 'package:guardaya_app/domain/usecases/categorias/actualizar_categoria.dart';
import 'package:guardaya_app/domain/usecases/categorias/crear_categoria.dart';
import 'package:guardaya_app/domain/usecases/categorias/desactivar_categoria.dart';
import 'package:guardaya_app/domain/usecases/categorias/listar_categorias.dart';

final categoriasDatasourceProvider = Provider<CategoriasDatasource>((ref) => CategoriasDatasource());
final categoriasRepositoryProvider = Provider((ref) => CategoriasRepositoryImpl(ref.watch(categoriasDatasourceProvider)));
final listarCategoriasProvider = Provider<ListarCategorias>((ref) => ListarCategorias(ref.watch(categoriasRepositoryProvider)));
final crearCategoriaProvider = Provider<CrearCategoria>((ref) => CrearCategoria(ref.watch(categoriasRepositoryProvider)));
final actualizarCategoriaProvider = Provider<ActualizarCategoria>((ref) => ActualizarCategoria(ref.watch(categoriasRepositoryProvider)));
final desactivarCategoriaProvider = Provider<DesactivarCategoria>((ref) => DesactivarCategoria(ref.watch(categoriasRepositoryProvider)));

final categoriasProvider = StateNotifierProvider<CategoriasNotifier, CategoriasState>((ref) {
  return CategoriasNotifier(
    listar: ref.watch(listarCategoriasProvider),
    crear: ref.watch(crearCategoriaProvider),
    actualizar: ref.watch(actualizarCategoriaProvider),
    desactivar: ref.watch(desactivarCategoriaProvider),
  );
});

class CategoriasState {
  final List<Categoria> categorias;
  final bool isLoading;
  final String? error;
  final bool success;

  const CategoriasState({
    this.categorias = const [],
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  CategoriasState copyWith({
    List<Categoria>? categorias,
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return CategoriasState(
      categorias: categorias ?? this.categorias,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class CategoriasNotifier extends StateNotifier<CategoriasState> {
  final ListarCategorias _listar;
  final CrearCategoria _crear;
  final ActualizarCategoria _actualizar;
  final DesactivarCategoria _desactivar;

  CategoriasNotifier({
    required ListarCategorias listar,
    required CrearCategoria crear,
    required ActualizarCategoria actualizar,
    required DesactivarCategoria desactivar,
  })  : _listar = listar,
        _crear = crear,
        _actualizar = actualizar,
        _desactivar = desactivar,
        super(const CategoriasState());

  Future<void> cargarCategorias(String empresaId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _listar(ListarCategoriasParams(empresaId: empresaId));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (categorias) => state = state.copyWith(isLoading: false, categorias: categorias),
    );
  }

  Future<void> crearCategoria(Categoria categoria) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _crear(CrearCategoriaParams(categoria: categoria));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (categoria) {
        state = state.copyWith(
          isLoading: false,
          categorias: [categoria, ...state.categorias],
          success: true,
        );
      },
    );
  }

  Future<void> actualizarCategoria(Categoria categoria) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _actualizar(ActualizarCategoriaParams(categoria: categoria));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (categoria) {
        final updated = state.categorias.map((c) => c.id == categoria.id ? categoria : c).toList();
        state = state.copyWith(isLoading: false, categorias: updated, success: true);
      },
    );
  }

  Future<void> desactivarCategoria(String categoriaId, {bool reactivar = false}) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _desactivar(DesactivarCategoriaParams(categoriaId: categoriaId, reactivar: reactivar));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        final updated = state.categorias.map((c) {
          if (c.id == categoriaId) return c.copyWith(activo: reactivar);
          return c;
        }).toList();
        state = state.copyWith(isLoading: false, categorias: updated, success: true);
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