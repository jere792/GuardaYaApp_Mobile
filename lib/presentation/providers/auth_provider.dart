import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/data/datasources/local/cache/secure_storage.dart';
import 'package:guardaya_app/data/datasources/remote/auth_datasource.dart';
import 'package:guardaya_app/data/repositories/implementations/auth_repository_impl.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/domain/repositories/auth_repository.dart';
import 'package:guardaya_app/domain/usecases/auth/login_usuario.dart';
import 'package:guardaya_app/domain/usecases/auth/logout_usuario.dart';
import 'package:guardaya_app/domain/usecases/auth/obtener_usuario_actual.dart';

final authDatasourceProvider = Provider<AuthDatasource>((ref) => AuthDatasource());
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(ref.watch(authDatasourceProvider)));

final loginProvider = Provider<LoginUsuario>((ref) => LoginUsuario(ref.watch(authRepositoryProvider)));
final logoutProvider = Provider<LogoutUsuario>((ref) => LogoutUsuario(ref.watch(authRepositoryProvider)));
final obtenerUsuarioProvider = Provider<ObtenerUsuarioActual>((ref) => ObtenerUsuarioActual(ref.watch(authRepositoryProvider)));

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    login: ref.watch(loginProvider),
    logout: ref.watch(logoutProvider),
    obtenerUsuario: ref.watch(obtenerUsuarioProvider),
  );
});

class AuthState {
  final Usuario? usuario;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool isOffline;

  const AuthState({
    this.usuario,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.isOffline = false,
  });

  AuthState copyWith({
    Usuario? usuario,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? isOffline,
  }) {
    return AuthState(
      usuario: usuario ?? this.usuario,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUsuario _login;
  final LogoutUsuario _logout;
  final ObtenerUsuarioActual _obtenerUsuario;

  AuthNotifier({
    required LoginUsuario login,
    required LogoutUsuario logout,
    required ObtenerUsuarioActual obtenerUsuario,
  })  : _login = login,
        _logout = logout,
        _obtenerUsuario = obtenerUsuario,
        super(const AuthState());

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null, isOffline: false);
    final result = await _login(LoginParams(username: username, password: password));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (usuario) => state = state.copyWith(isLoading: false, usuario: usuario, isAuthenticated: true, isOffline: false),
    );
  }

  Future<void> logout() async {
    await _logout(const NoParams());
    await SecureStorage.setOfflineMode(false);
    state = const AuthState();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      // 1. Verificar si hay sesión almacenada
      final result = await _obtenerUsuario(const NoParams());
      result.fold(
        (failure) => state = state.copyWith(isLoading: false, isAuthenticated: false, isOffline: false),
        (usuario) async {
          if (usuario == null) {
            state = state.copyWith(isLoading: false, isAuthenticated: false, isOffline: false);
            return;
          }

          // 2. Verificar si hay conexión y si el usuario sigue activo en el servidor
          try {
            final repo = AuthRepositoryImpl(AuthDatasource());
            final isAuth = await repo.isAuthenticated();
            isAuth.fold(
              (failure) {
                // Si falla, probablemente no hay internet => modo offline
                state = state.copyWith(
                  isLoading: false,
                  usuario: usuario,
                  isAuthenticated: true,
                  isOffline: true,
                );
              },
              (authenticated) {
                state = state.copyWith(
                  isLoading: false,
                  usuario: usuario,
                  isAuthenticated: authenticated,
                  isOffline: !authenticated,
                );
              },
            );
          } catch (e) {
            // Error de red => modo offline
            state = state.copyWith(
              isLoading: false,
              usuario: usuario,
              isAuthenticated: true,
              isOffline: true,
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isAuthenticated: false, isOffline: false);
    }
  }

  /// Marca el estado como offline (usado por el ConnectivityProvider)
  void setOffline(bool offline) {
    if (state.isAuthenticated) {
      state = state.copyWith(isOffline: offline);
    }
  }
}
