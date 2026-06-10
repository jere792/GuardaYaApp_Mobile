import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/domain/usecases/auth/login_usuario.dart';
import 'package:guardaya_app/domain/usecases/auth/logout_usuario.dart';
import 'package:guardaya_app/domain/usecases/auth/obtener_usuario_actual.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    login: ref.watch(loginProvider),
    logout: ref.watch(logoutProvider),
    obtenerUsuario: ref.watch(obtenerUsuarioProvider),
  );
});

final loginProvider = Provider<LoginUsuario>((ref) {
  // TODO: Inyectar repositorio real
  throw UnimplementedError();
});

final logoutProvider = Provider<LogoutUsuario>((ref) {
  // TODO: Inyectar repositorio real
  throw UnimplementedError();
});

final obtenerUsuarioProvider = Provider<ObtenerUsuarioActual>((ref) {
  // TODO: Inyectar repositorio real
  throw UnimplementedError();
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