import 'dart:convert';
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

  static const Duration _sessionMaxDuration = Duration(days: 30);
  static const Duration _offlineMaxDuration = Duration(days: 7);
  static const Duration _tokenExpiryBuffer = Duration(hours: 1);
  static const int _maxLoginAttempts = 5;
  static const Duration _loginCooldown = Duration(minutes: 15);

  AuthRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, Usuario>> login(String username, String password) async {
    try {
      final attempts = await SecureStorage.getLoginAttempts();
      if (attempts >= _maxLoginAttempts) {
        return Left(AuthFailure('Demasiados intentos. Intenta de nuevo en $_loginCooldown.'));
      }

      final loginData = await _datasource.login(username, password);
      final userData = loginData['user'] as Map<String, dynamic>?;

      if (userData == null) {
        return Left(AuthFailure('No se obtuvo datos de usuario'));
      }

      await SecureStorage.clearLoginAttempts();
      await SecureStorage.setOfflineMode(false);

      final usuario = UsuarioModel.fromJson(userData);
      final token = loginData['token'] as String?;
      final expiresAt = loginData['expires_at'] as String?;

      await SecureStorage.saveUser(jsonEncode(usuario.toJson()));
      await SecureStorage.saveEmpresaId(usuario.empresaId ?? '');
      await SecureStorage.saveSessionStartedAt(DateTime.now());
      await SecureStorage.saveLastVerifiedAt(DateTime.now());

      if (token != null) {
        await SecureStorage.saveSession(token);
      }
      if (expiresAt != null) {
        final parsed = DateTime.tryParse(expiresAt);
        if (parsed != null) {
          await SecureStorage.saveTokenExpiresAt(parsed);
        }
      }

      return Right(usuario.toEntity());
    } on AuthException catch (_) {
      await SecureStorage.incrementLoginAttempts();
      return Left(AuthFailure('Usuario o contraseña incorrectos'));
    } catch (_) {
      return Left(ServerFailure('Error de conexión'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final token = await SecureStorage.getSession();
      if (token != null) {
        await _datasource.logout(token);
      }
      await SecureStorage.clearAll();
      return const Right(null);
    } catch (e) {
      await SecureStorage.clearAll();
      return const Right(null);
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

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final userJson = await SecureStorage.getUser();
      if (userJson == null) return const Right(false);

      final map = jsonDecode(userJson) as Map<String, dynamic>;
      final username = map['username'] as String?;
      if (username == null) return const Right(false);

      final sessionStartedAt = await SecureStorage.getSessionStartedAt();
      if (sessionStartedAt != null) {
        if (DateTime.now().difference(sessionStartedAt) > _sessionMaxDuration) {
          await SecureStorage.clearAll();
          return const Right(false);
        }
      }

      // Verificar expiración del token
      final expiresAt = await SecureStorage.getTokenExpiresAt();
      if (expiresAt != null) {
        if (DateTime.now().isAfter(expiresAt.subtract(_tokenExpiryBuffer))) {
          final token = await SecureStorage.getSession();
          if (token != null) {
            try {
              final refreshData = await _datasource.refreshSession(token);
              final newToken = refreshData['token'] as String?;
              final newExpiresAt = refreshData['expires_at'] as String?;
              if (newToken != null) await SecureStorage.saveSession(newToken);
              if (newExpiresAt != null) {
                final parsed = DateTime.tryParse(newExpiresAt);
                if (parsed != null) await SecureStorage.saveTokenExpiresAt(parsed);
              }
            } catch (_) {
              await SecureStorage.clearAll();
              return const Right(false);
            }
          } else {
            await SecureStorage.clearAll();
            return const Right(false);
          }
        }
      }

      final isActive = await _datasource.verifyUsuarioActivo(username);
      if (isActive) {
        await SecureStorage.setOfflineMode(false);
        await SecureStorage.saveLastVerifiedAt(DateTime.now());
        return const Right(true);
      }

      final lastVerifiedAt = await SecureStorage.getLastVerifiedAt();
      if (lastVerifiedAt != null) {
        if (DateTime.now().difference(lastVerifiedAt) > _offlineMaxDuration) {
          await SecureStorage.clearAll();
          return const Right(false);
        }
      }

      await SecureStorage.setOfflineMode(true);
      return const Right(true);
    } catch (e) {
      final sessionStartedAt = await SecureStorage.getSessionStartedAt();
      if (sessionStartedAt != null) {
        if (DateTime.now().difference(sessionStartedAt) > _sessionMaxDuration) {
          await SecureStorage.clearAll();
          return const Right(false);
        }
      }

      final lastVerifiedAt = await SecureStorage.getLastVerifiedAt();
      if (lastVerifiedAt != null) {
        if (DateTime.now().difference(lastVerifiedAt) > _offlineMaxDuration) {
          await SecureStorage.clearAll();
          return const Right(false);
        }
      }

      // Si hay token local, intentar refresh antes de rendirnos
      final token = await SecureStorage.getSession();
      if (token != null) {
        try {
          final refreshData = await _datasource.refreshSession(token);
          final newToken = refreshData['token'] as String?;
          if (newToken != null) await SecureStorage.saveSession(newToken);
          return const Right(true);
        } catch (_) {
          return const Right(true);
        }
      }

      return const Right(true);
    }
  }

  Future<Either<Failure, bool>> refreshSessionIfNeeded() async {
    return const Right(true);
  }
}
