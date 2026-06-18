import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/repositories/usuario_repository.dart';

class CambiarPassword implements UseCase<void, CambiarPasswordParams> {
  final UsuarioRepository repository;
  CambiarPassword(this.repository);

  @override
  Future<Either<Failure, void>> call(CambiarPasswordParams params) async {
    return await repository.cambiarPassword(params.userId, params.newPassword);
  }
}

class CambiarPasswordParams {
  final String userId;
  final String newPassword;
  CambiarPasswordParams({required this.userId, required this.newPassword});
}
