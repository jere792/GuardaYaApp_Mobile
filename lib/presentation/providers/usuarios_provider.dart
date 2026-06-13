import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/data/datasources/remote/usuario_datasource.dart';
import 'package:guardaya_app/data/repositories/implementations/usuario_repository_impl.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/domain/usecases/usuarios/crear_usuario.dart';
import 'package:guardaya_app/domain/usecases/usuarios/desactivar_usuario.dart';
import 'package:guardaya_app/domain/usecases/usuarios/listar_usuarios.dart';

final usuarioDatasourceProvider = Provider<UsuarioDatasource>((ref) => UsuarioDatasource());
final usuarioRepositoryProvider = Provider((ref) => UsuarioRepositoryImpl(ref.watch(usuarioDatasourceProvider)));
final crearUsuarioProvider = Provider<CrearUsuario>((ref) => CrearUsuario(ref.watch(usuarioRepositoryProvider)));
final listarUsuariosProvider = Provider<ListarUsuarios>((ref) => ListarUsuarios(ref.watch(usuarioRepositoryProvider)));
final desactivarUsuarioProvider = Provider<DesactivarUsuario>((ref) => DesactivarUsuario(ref.watch(usuarioRepositoryProvider)));

final usuariosProvider = StateNotifierProvider<UsuariosNotifier, UsuariosState>((ref) {
  return UsuariosNotifier(
    crear: ref.watch(crearUsuarioProvider),
    listar: ref.watch(listarUsuariosProvider),
    desactivar: ref.watch(desactivarUsuarioProvider),
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
  final DesactivarUsuario _desactivar;

  UsuariosNotifier({
    required CrearUsuario crear,
    required ListarUsuarios listar,
    required DesactivarUsuario desactivar,
  })  : _crear = crear,
        _listar = listar,
        _desactivar = desactivar,
        super(const UsuariosState());

  Future<void> crearEmpleado({
    required String username,
    required String password,
    required String nombre,
    String? apellidos,
    String? telefono,
    String? email,
    String? empresaId,
    required String rolNombre,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _crear(CrearUsuarioParams(
      username: username,
      password: password,
      nombre: nombre,
      apellidos: apellidos,
      telefono: telefono,
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

  Future<void> desactivarEmpleado(String userId) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await _desactivar(DesactivarUsuarioParams(userId: userId));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        // Actualizar el estado local del usuario
        final updatedUsuarios = state.usuarios.map((u) {
          if (u.id == userId) {
            return Usuario(
              id: u.id,
              username: u.username,
              nombre: u.nombre,
              apellidos: u.apellidos,
              telefono: u.telefono,
              email: u.email,
              rolId: u.rolId,
              empresaId: u.empresaId,
              activo: false,
              createdAt: u.createdAt,
            );
          }
          return u;
        }).toList();
        state = state.copyWith(isLoading: false, usuarios: updatedUsuarios.cast<Usuario>(), success: true);
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
