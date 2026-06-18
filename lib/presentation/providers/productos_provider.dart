import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/data/datasources/remote/productos_datasource.dart';
import 'package:guardaya_app/data/repositories/implementations/productos_repository_impl.dart';
import 'package:guardaya_app/domain/entities/producto.dart';
import 'package:guardaya_app/domain/usecases/productos/actualizar_producto.dart';
import 'package:guardaya_app/domain/usecases/productos/crear_producto.dart';
import 'package:guardaya_app/domain/usecases/productos/desactivar_producto.dart';
import 'package:guardaya_app/domain/usecases/productos/listar_productos.dart';

final productosDatasourceProvider = Provider<ProductosDatasource>((ref) => ProductosDatasource());
final productosRepositoryProvider = Provider((ref) => ProductosRepositoryImpl(ref.watch(productosDatasourceProvider)));
final listarProductosProvider = Provider<ListarProductos>((ref) => ListarProductos(ref.watch(productosRepositoryProvider)));
final crearProductoProvider = Provider<CrearProducto>((ref) => CrearProducto(ref.watch(productosRepositoryProvider)));
final actualizarProductoProvider = Provider<ActualizarProducto>((ref) => ActualizarProducto(ref.watch(productosRepositoryProvider)));
final desactivarProductoProvider = Provider<DesactivarProducto>((ref) => DesactivarProducto(ref.watch(productosRepositoryProvider)));

final productosProvider = StateNotifierProvider<ProductosNotifier, ProductosState>((ref) {
  return ProductosNotifier(
    listar: ref.watch(listarProductosProvider),
    crear: ref.watch(crearProductoProvider),
    actualizar: ref.watch(actualizarProductoProvider),
    desactivar: ref.watch(desactivarProductoProvider),
  );
});

class ProductosState {
  final List<Producto> productos;
  final bool isLoading;
  final String? error;
  final bool success;

  const ProductosState({
    this.productos = const [],
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  ProductosState copyWith({
    List<Producto>? productos,
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return ProductosState(
      productos: productos ?? this.productos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class ProductosNotifier extends StateNotifier<ProductosState> {
  final ListarProductos _listar;
  final CrearProducto _crear;
  final ActualizarProducto _actualizar;
  final DesactivarProducto _desactivar;

  ProductosNotifier({
    required ListarProductos listar,
    required CrearProducto crear,
    required ActualizarProducto actualizar,
    required DesactivarProducto desactivar,
  })  : _listar = listar,
        _crear = crear,
        _actualizar = actualizar,
        _desactivar = desactivar,
        super(const ProductosState());

  Future<void> cargarProductos(String empresaId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _listar(ListarProductosParams(empresaId: empresaId));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (productos) => state = state.copyWith(isLoading: false, productos: productos),
    );
  }

  Future<void> crearProducto(Producto producto) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _crear(CrearProductoParams(producto: producto));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (producto) {
        state = state.copyWith(
          isLoading: false,
          productos: [producto, ...state.productos],
          success: true,
        );
      },
    );
  }

  Future<void> actualizarProducto(Producto producto) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _actualizar(ActualizarProductoParams(producto: producto));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (producto) {
        final updated = state.productos.map((p) => p.id == producto.id ? producto : p).toList();
        state = state.copyWith(isLoading: false, productos: updated, success: true);
      },
    );
  }

  Future<void> desactivarProducto(String productoId, {bool reactivar = false}) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _desactivar(DesactivarProductoParams(productoId: productoId, reactivar: reactivar));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        final updated = state.productos.map((p) {
          if (p.id == productoId) return p.copyWith(activo: reactivar);
          return p;
        }).toList();
        state = state.copyWith(isLoading: false, productos: updated, success: true);
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
