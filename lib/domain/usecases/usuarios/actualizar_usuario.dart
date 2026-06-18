import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/repositories/usuario_repository.dart';

class ActualizarUsuario implements UseCase<void, ActualizarUsuarioParams> {
  final UsuarioRepository repository;
  ActualizarUsuario(this.repository);

  @override
  Future<Either<Failure, void>> call(ActualizarUsuarioParams params) async {
    return await repository.actualizarUsuario(
      userId: params.userId,
      nombre: params.nombre,
      username: params.username,
      email: params.email,
      telefono: params.telefono,
      rolNombre: params.rolNombre,
    );
  }
}

class ActualizarUsuarioParams {
  final String userId;
  final String nombre;
  final String username;
  final String? email;
  final String? telefono;
  final String rolNombre;

  ActualizarUsuarioParams({
    required this.userId,
    required this.nombre,
    required this.username,
    this.email,
    this.telefono,
    required this.rolNombre,
  });
}
