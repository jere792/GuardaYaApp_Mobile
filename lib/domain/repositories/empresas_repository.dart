import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/domain/entities/empresa.dart';

abstract class EmpresasRepository {
  Future<Either<Failure, List<Empresa>>> listarEmpresas();
  Future<Either<Failure, Empresa>> crearEmpresa(Empresa empresa);
  Future<Either<Failure, Empresa>> actualizarEmpresa(Empresa empresa);
  Future<Either<Failure, void>> desactivarEmpresa(String empresaId, {bool reactivar = false});
}
