import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/data/datasources/remote/usuario_datasource.dart';
import 'package:guardaya_app/data/models/usuario_model.dart';
import 'package:guardaya_app/domain/entities/usuario.dart';
import 'package:guardaya_app/domain/repositories/usuario_repository.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final UsuarioDatasource _datasource;

  UsuarioRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, Usuario>> crearUsuario({
    required String username,
    required String password,
    required String nombre,
    String? apellidos,
    String? telefono,
    String? email,
    String? empresaId,
    required String rolNombre,
  }) async {
    try {
      final data = await _datasource.crearUsuario(
        username: username,
        password: password,
        nombre: nombre,
        apellidos: apellidos,
        telefono: telefono,
        email: email,
        empresaId: empresaId,
        rolNombre: rolNombre,
      );
      final usuario = UsuarioModel.fromJson(data).toEntity();
      return Right(usuario);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Usuario>>> listarUsuarios(String empresaId) async {
    try {
      final list = await _datasource.listarUsuarios(empresaId);
      final usuarios = list
          .map((json) => UsuarioModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Right(usuarios);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> desactivarUsuario(String userId) async {
    try {
      await _datasource.desactivarUsuario(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
