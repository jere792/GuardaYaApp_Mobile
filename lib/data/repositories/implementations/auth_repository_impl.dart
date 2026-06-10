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
  Future<<Either<Failure, Usuario>> login(String username, String password) async {
    try {
      final data = await _datasource.login(username, password);
      final token = data['token'] as String?;
      final usuario = UsuarioModel.fromJson(data['usuario'] as Map<String, dynamic>);
      
      if (token != null) {
        await SecureStorage.saveSession(token);
        await SecureStorage.saveEmpresaId(usuario.empresaId ?? '');
      }
      
      return Right(usuario.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<<Either<Failure, void>> logout() async {
    try {
      await SecureStorage.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<<Either<Failure, Usuario?>> getUsuarioActual() async {
    try {
      final token = await SecureStorage.getSession();
      if (token == null) return const Right(null);
      
      // TODO: Obtener usuario desde Supabase usando el token
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await SecureStorage.getSession();
      return Right(token != null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}