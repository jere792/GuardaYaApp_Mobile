import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/data/datasources/remote/clientes_datasource.dart';
import 'package:guardaya_app/data/repositories/implementations/clientes_repository_impl.dart';
import 'package:guardaya_app/domain/entities/cliente.dart';
import 'package:guardaya_app/domain/usecases/clientes/actualizar_cliente.dart';
import 'package:guardaya_app/domain/usecases/clientes/crear_cliente.dart';
import 'package:guardaya_app/domain/usecases/clientes/desactivar_cliente.dart';
import 'package:guardaya_app/domain/usecases/clientes/listar_clientes.dart';

final clientesDatasourceProvider = Provider<ClientesDatasource>((ref) => ClientesDatasource());
final clientesRepositoryProvider = Provider((ref) => ClientesRepositoryImpl(ref.watch(clientesDatasourceProvider)));
final listarClientesProvider = Provider<ListarClientes>((ref) => ListarClientes(ref.watch(clientesRepositoryProvider)));
final crearClienteProvider = Provider<CrearClienteUsecase>((ref) => CrearClienteUsecase(ref.watch(clientesRepositoryProvider)));
final actualizarClienteProvider = Provider<ActualizarCliente>((ref) => ActualizarCliente(ref.watch(clientesRepositoryProvider)));
final desactivarClienteProvider = Provider<DesactivarCliente>((ref) => DesactivarCliente(ref.watch(clientesRepositoryProvider)));

final clientesProvider = StateNotifierProvider<ClientesNotifier, ClientesState>((ref) {
  return ClientesNotifier(
    listar: ref.watch(listarClientesProvider),
    crear: ref.watch(crearClienteProvider),
    actualizar: ref.watch(actualizarClienteProvider),
    desactivar: ref.watch(desactivarClienteProvider),
  );
});

class ClientesState {
  final List<Cliente> clientes;
  final bool isLoading;
  final String? error;
  final bool success;

  const ClientesState({
    this.clientes = const [],
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  ClientesState copyWith({
    List<Cliente>? clientes,
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return ClientesState(
      clientes: clientes ?? this.clientes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class ClientesNotifier extends StateNotifier<ClientesState> {
  final ListarClientes _listar;
  final CrearClienteUsecase _crear;
  final ActualizarCliente _actualizar;
  final DesactivarCliente _desactivar;

  ClientesNotifier({
    required ListarClientes listar,
    required CrearClienteUsecase crear,
    required ActualizarCliente actualizar,
    required DesactivarCliente desactivar,
  })  : _listar = listar,
        _crear = crear,
        _actualizar = actualizar,
        _desactivar = desactivar,
        super(const ClientesState());

  Future<void> cargarClientes(String empresaId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _listar(ListarClientesParams(empresaId: empresaId));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (clientes) => state = state.copyWith(isLoading: false, clientes: clientes),
    );
  }

  Future<void> crearCliente(Cliente cliente) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _crear(CrearClienteParams(cliente: cliente));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (cliente) {
        state = state.copyWith(
          isLoading: false,
          clientes: [cliente, ...state.clientes],
          success: true,
        );
      },
    );
  }

  Future<void> actualizarCliente(Cliente cliente) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _actualizar(ActualizarClienteParams(cliente: cliente));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (cliente) {
        final updated = state.clientes.map((c) => c.id == cliente.id ? cliente : c).toList();
        state = state.copyWith(isLoading: false, clientes: updated, success: true);
      },
    );
  }

  Future<void> desactivarCliente(String clienteId, {bool reactivar = false}) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _desactivar(DesactivarClienteParams(clienteId: clienteId, reactivar: reactivar));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        final updated = state.clientes.map((c) {
          if (c.id == clienteId) return c.copyWith(activo: reactivar);
          return c;
        }).toList();
        state = state.copyWith(isLoading: false, clientes: updated, success: true);
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