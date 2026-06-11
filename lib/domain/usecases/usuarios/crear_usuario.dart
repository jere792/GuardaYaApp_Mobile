import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/domain/repositories/usuario_repository.dart';

class CrearUsuario implements UseCase<Usuario, CrearUsuarioParams> {
  final UsuarioRepository repository;
  CrearUsuario(this.repository);

  @override
  Future<Either<Failure, Usuario>> call(CrearUsuarioParams params) async {
    return await repository.crearUsuario(
      username: params.username,
      password: params.password,
      nombre: params.nombre,
      email: params.email,
      empresaId: params.empresaId,
      rolNombre: params.rolNombre,
    );
  }
}

class CrearUsuarioParams {
  final String username;
  final String password;
  final String nombre;
  final String? email;
  final String empresaId;
  final String rolNombre;

  CrearUsuarioParams({
    required this.username,
    required this.password,
    required this.nombre,
    this.email,
    required this.empresaId,
    required this.rolNombre,
  });
}
