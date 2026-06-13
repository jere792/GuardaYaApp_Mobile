import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/repositories/usuario_repository.dart';

class DesactivarUsuario implements UseCase<void, DesactivarUsuarioParams> {
  final UsuarioRepository repository;
  DesactivarUsuario(this.repository);

  @override
  Future<Either<Failure, void>> call(DesactivarUsuarioParams params) async {
    return await repository.desactivarUsuario(params.userId);
  }
}

class DesactivarUsuarioParams {
  final String userId;
  DesactivarUsuarioParams({required this.userId});
}