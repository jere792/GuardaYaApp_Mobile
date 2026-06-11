import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/data/datasources/remote/usuario_datasource.dart';
import 'package:guardaya_app/data/repositories/implementations/usuario_repository_impl.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/domain/usecases/usuarios/crear_usuario.dart';
import 'package:guardaya_app/domain/usecases/usuarios/listar_usuarios.dart';

final usuarioDatasourceProvider = Provider<UsuarioDatasource>((ref) => UsuarioDatasource());
final usuarioRepositoryProvider = Provider((ref) => UsuarioRepositoryImpl(ref.watch(usuarioDatasourceProvider)));
final crearUsuarioProvider = Provider<CrearUsuario>((ref) => CrearUsuario(ref.watch(usuarioRepositoryProvider)));
final listarUsuariosProvider = Provider<ListarUsuarios>((ref) => ListarUsuarios(ref.watch(usuarioRepositoryProvider)));

final usuariosProvider = StateNotifierProvider<UsuariosNotifier, UsuariosState>((ref) {
  return UsuariosNotifier(
    crear: ref.watch(crearUsuarioProvider),
    listar: ref.watch(listarUsuariosProvider),
  );
});

class UsuariosState {
  final List<Usuario> usuarios;
  final bool isLoading;
  final String? error;
  final bool success;

  const UsuariosState({
    this.usuarios = const [],
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  UsuariosState copyWith({
    List<Usuario>? usuarios,
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return UsuariosState(
      usuarios: usuarios ?? this.usuarios,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class UsuariosNotifier extends StateNotifier<UsuariosState> {
  final CrearUsuario _crear;
  final ListarUsuarios _listar;

  UsuariosNotifier({
    required CrearUsuario crear,
    required ListarUsuarios listar,
  })  : _crear = crear,
        _listar = listar,
        super(const UsuariosState());

  Future<void> crearEmpleado({
    required String username,
    required String password,
    required String nombre,
    String? email,
    required String empresaId,
    required String rolNombre,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _crear(CrearUsuarioParams(
      username: username,
      password: password,
      nombre: nombre,
      email: email,
      empresaId: empresaId,
      rolNombre: rolNombre,
    ));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(isLoading: false, success: true),
    );
  }

  Future<void> cargarEmpleados(String empresaId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _listar(ListarUsuariosParams(empresaId: empresaId));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (usuarios) => state = state.copyWith(isLoading: false, usuarios: usuarios),
    );
  }

  void resetSuccess() {
    state = state.copyWith(success: false);
  }

  void resetError() {
    state = state.copyWith(error: null);
  }
}
