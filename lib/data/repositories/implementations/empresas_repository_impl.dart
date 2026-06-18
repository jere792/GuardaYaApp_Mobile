import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/data/datasources/remote/empresas_datasource.dart';
import 'package:guardaya_app/data/models/empresa_model.dart';
import 'package:guardaya_app/domain/entities/empresa.dart';
import 'package:guardaya_app/domain/repositories/empresas_repository.dart';

class EmpresasRepositoryImpl implements EmpresasRepository {
  final EmpresasDatasource _datasource;

  EmpresasRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<Empresa>>> listarEmpresas() async {
    try {
      final list = await _datasource.listarEmpresas();
      final empresas = list
          .map((json) => EmpresaModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Right(empresas);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Empresa>> crearEmpresa(Empresa empresa) async {
    try {
      final data = await _datasource.crearEmpresa({
        'nombre': empresa.nombre,
        'slug': empresa.slug,
        'email_contacto': empresa.emailContacto,
        'telefono': empresa.telefono,
        'direccion': empresa.direccion,
        'ruc_dni': empresa.rucDni,
        'logo_url': empresa.logoUrl,
        'plan': empresa.plan,
        'limite_usuarios': empresa.limiteUsuarios,
        'activo': empresa.activo,
        'created_at': empresa.createdAt.toIso8601String(),
      });
      return Right(EmpresaModel.fromJson(data).toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Empresa>> actualizarEmpresa(Empresa empresa) async {
    try {
      final data = await _datasource.actualizarEmpresa(empresa.id, {
        'nombre': empresa.nombre,
        'slug': empresa.slug,
        'email_contacto': empresa.emailContacto,
        'telefono': empresa.telefono,
        'direccion': empresa.direccion,
        'ruc_dni': empresa.rucDni,
        'logo_url': empresa.logoUrl,
        'plan': empresa.plan,
        'limite_usuarios': empresa.limiteUsuarios,
      });
      return Right(EmpresaModel.fromJson(data).toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> desactivarEmpresa(String empresaId, {bool reactivar = false}) async {
    try {
      if (reactivar) {
        await _datasource.reactivarEmpresa(empresaId);
      } else {
        await _datasource.desactivarEmpresa(empresaId);
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
