import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/domain/repositories/usuario_repository.dart';

class ListarUsuarios implements UseCase<List<Usuario>, ListarUsuariosParams> {
  final UsuarioRepository repository;
  ListarUsuarios(this.repository);

  @override
  Future<Either<Failure, List<Usuario>>> call(ListarUsuariosParams params) async {
    return await repository.listarUsuarios(params.empresaId, params.rol);
  }
}

class ListarUsuariosParams {
  final String? empresaId;
  final String rol;
  ListarUsuariosParams({this.empresaId, required this.rol});
}
