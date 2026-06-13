import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/data/datasources/local/cache/secure_storage.dart';
import 'package:guardaya_app/data/datasources/remote/auth_datasource.dart';
import 'package:guardaya_app/data/models/empresa_colors.dart';
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
      
      // 1. Login con Supabase Auth nativo (JWT real)
      final authResponse = await _datasource.login(username, password);
      final session = authResponse.session;

      debugPrint('AuthRepositoryImpl.login: Session=${session != null}');

      if (session == null) {
        return Left(AuthFailure('No se obtuvo sesión'));
      }

      // 2. Guardar JWT y refresh token
      await SecureStorage.saveSession(session.accessToken);
      if (session.refreshToken != null) {
        await SecureStorage.saveRefreshToken(session.refreshToken!);
      }
      if (session.expiresAt != null) {
        await SecureStorage.saveTokenExpiresAt(
          DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
        );
      }
      await SecureStorage.setOfflineMode(false);

      // 3. Obtener datos de usuario, empresa y colores
      debugPrint('AuthRepositoryImpl.login: Getting user data...');
      final userData = await _datasource.getUsuarioCompleto();
      debugPrint('AuthRepositoryImpl.login: User data=$userData');
      
      final usuario = UsuarioModel.fromJson(userData);
      final empresaData = userData['empresa'] as Map<String, dynamic>?;

      // 4. Guardar en local storage
      await SecureStorage.saveUser(jsonEncode(usuario.toJson()));
      await SecureStorage.saveEmpresaId(usuario.empresaId ?? '');
      if (empresaData != null) {
        await SecureStorage.saveEmpresaColors(jsonEncode(empresaData));
      }

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
  Future<Either<Failure, EmpresaColors>> getEmpresaColors() async {
    try {
      final colorsJson = await SecureStorage.getEmpresaColors();
      if (colorsJson == null) return const Right(EmpresaColors());
      final map = jsonDecode(colorsJson) as Map<String, dynamic>;
      return Right(EmpresaColors.fromJson(map));
    } catch (e) {
      return const Right(EmpresaColors());
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

  /// Verifica la sesión con el servidor.
  /// Si hay internet y el usuario está activo, devuelve true.
  /// Si no hay internet, mantiene la sesión local (modo offline).
  /// Si hay internet pero el usuario está inactivo, desloguea.
  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await SecureStorage.getSession();
      if (token == null) return const Right(false);

      final expiresAt = await SecureStorage.getTokenExpiresAt();
      if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
        // Token expirado, intentar renovar
        final refreshToken = await SecureStorage.getRefreshToken();
        if (refreshToken != null) {
          try {
            final authResponse = await _datasource.refreshSession(refreshToken);
            final session = authResponse.session;
            if (session != null) {
              await SecureStorage.saveSession(session.accessToken);
              if (session.refreshToken != null) {
                await SecureStorage.saveRefreshToken(session.refreshToken!);
              }
              if (session.expiresAt != null) {
                await SecureStorage.saveTokenExpiresAt(
                  DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
                );
              }
            }
          } catch (e) {
            // Si falla el refresh, desloguear
            await SecureStorage.clearAll();
            return const Right(false);
          }
        }
      }

      // Verificar con servidor si hay conectividad
      final isActive = await _datasource.verifyUsuarioActivo();
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

  /// Intenta refrescar la sesión antes de que expire.
  Future<Either<Failure, bool>> refreshSessionIfNeeded() async {
    try {
      final expiresAt = await SecureStorage.getTokenExpiresAt();
      if (expiresAt == null) return const Right(false);

      // Si expira en menos de 5 minutos, renovar
      if (expiresAt.difference(DateTime.now()).inMinutes < 5) {
        final refreshToken = await SecureStorage.getRefreshToken();
        if (refreshToken == null) return const Right(false);

        final authResponse = await _datasource.refreshSession(refreshToken);
        final session = authResponse.session;
        if (session != null) {
          await SecureStorage.saveSession(session.accessToken);
          if (session.refreshToken != null) {
            await SecureStorage.saveRefreshToken(session.refreshToken!);
          }
          if (session.expiresAt != null) {
            await SecureStorage.saveTokenExpiresAt(
              DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
            );
          }
          return const Right(true);
        }
      }
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
