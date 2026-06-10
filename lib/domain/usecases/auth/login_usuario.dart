import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/domain/repositories/auth_repository.dart';

class LoginUsuario implements UseCase<Usuario, LoginParams> {
  final AuthRepository repository;
  LoginUsuario(this.repository);

  @override
  Future<<Either<Failure, Usuario>> call(LoginParams params) async {
    return await repository.login(params.username, params.password);
  }
}

class LoginParams {
  final String username;
  final String password;
  LoginParams({required this.username, required this.password});
}