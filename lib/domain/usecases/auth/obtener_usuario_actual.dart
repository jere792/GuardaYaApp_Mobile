import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/domain/repositories/auth_repository.dart';

class ObtenerUsuarioActual implements UseCase<Usuario?, NoParams> {
  final AuthRepository repository;
  ObtenerUsuarioActual(this.repository);

  @override
  Future<Either<Failure, Usuario?>> call(NoParams params) async {
    return await repository.getUsuarioActual();
  }
}
