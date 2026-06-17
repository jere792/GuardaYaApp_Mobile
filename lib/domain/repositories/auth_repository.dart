import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';

abstract class AuthRepository {
  Future<Either<Failure, Usuario>> login(String username, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, Usuario?>> getUsuarioActual();
  Future<Either<Failure, bool>> isAuthenticated();
}
