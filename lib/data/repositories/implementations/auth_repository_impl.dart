import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/data/datasources/local/cache/secure_storage.dart';
import 'package:guardaya_app/data/datasources/remote/auth_datasource.dart';
import 'package:guardaya_app/data/models/usuario_model.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, Usuario>> login(String username, String password) async {
    try {
      debugPrint('AuthRepositoryImpl.login: Starting login for $username');
      
      // 1. Login validado contra public.usuarios con bcrypt (no usa Supabase Auth)
      final loginData = await _datasource.login(username, password);
      final userData = loginData['user'] as Map<String, dynamic>?;

      if (userData == null) {
        return Left(AuthFailure('No se obtuvo datos de usuario'));
      }

      debugPrint('AuthRepositoryImpl.login: User validated via bcrypt');
      await SecureStorage.setOfflineMode(false);

      // 2. Guardar usuario en local storage
      final usuario = UsuarioModel.fromJson(userData);

      await SecureStorage.saveUser(jsonEncode(usuario.toJson()));
      await SecureStorage.saveEmpresaId(usuario.empresaId ?? '');

      debugPrint('AuthRepositoryImpl.login: Success!');
      return Right(usuario.toEntity());
    } on AuthException catch (_) {
      debugPrint('AuthRepositoryImpl.login: AuthException - Invalid credentials');
      return Left(AuthFailure('Usuario o contraseña incorrectos'));
    } catch (_) {
      debugPrint('AuthRepositoryImpl.login: Exception - Connection error');
      return Left(ServerFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _datasource.logout();
      await SecureStorage.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Usuario?>> getUsuarioActual() async {
    try {
      final userJson = await SecureStorage.getUser();
      if (userJson == null) return const Right(null);

      final map = jsonDecode(userJson) as Map<String, dynamic>;
      final usuario = UsuarioModel.fromJson(map).toEntity();

      return Right(usuario);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Verifica si hay un usuario guardado localmente.
  /// Si hay internet, verifica que el usuario siga activo en el servidor.
  /// Si no hay internet, confía en la sesión local (modo offline).
  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final userJson = await SecureStorage.getUser();
      if (userJson == null) return const Right(false);

      final map = jsonDecode(userJson) as Map<String, dynamic>;
      final username = map['username'] as String?;
      if (username == null) return const Right(false);

      // Verificar con servidor si hay conectividad
      final isActive = await _datasource.verifyUsuarioActivo(username);
      if (isActive) {
        await SecureStorage.setOfflineMode(false);
        return const Right(true);
      }

      // Si no hay internet o el servidor no responde, confiar en sesión local
      // (modo offline)
      return const Right(true);
    } catch (e) {
      // En caso de error (probablemente no hay internet), confiar en sesión local
      return const Right(true);
    }
  }

  /// No aplica en el nuevo sistema sin JWT. Mantiene compatibilidad.
  Future<Either<Failure, bool>> refreshSessionIfNeeded() async {
    return const Right(true);
  }
}
