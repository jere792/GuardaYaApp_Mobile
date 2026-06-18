import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';

abstract class UsuarioRepository {
  Future<Either<Failure, Usuario>> crearUsuario({
    required String username,
    required String password,
    required String nombre,
    String? apellidos,
    String? telefono,
    String? email,
    String? empresaId,
    required String rolNombre,
  });

  Future<Either<Failure, List<Usuario>>> listarUsuarios(String? empresaId, String rol);

  Future<Either<Failure, void>> desactivarUsuario(String userId);

  Future<Either<Failure, void>> actualizarUsuario({
    required String userId,
    required String nombre,
    required String username,
    String? email,
    String? telefono,
    required String rolNombre,
  });
}
