import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
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

  const AuthState({
    this.usuario,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    Usuario? usuario,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      usuario: usuario ?? this.usuario,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
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
    state = state.copyWith(isLoading: true, error: null);
    final result = await _login(LoginParams(username: username, password: password));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (usuario) => state = state.copyWith(isLoading: false, usuario: usuario, isAuthenticated: true),
    );
  }

  Future<void> logout() async {
    await _logout(const NoParams());
    state = const AuthState();
  }

  Future<void> checkAuth() async {
    final result = await _obtenerUsuario(const NoParams());
    result.fold(
      (failure) => state = state.copyWith(isAuthenticated: false),
      (usuario) => state = state.copyWith(usuario: usuario, isAuthenticated: usuario != null),
    );
  }
}
