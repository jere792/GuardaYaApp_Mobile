import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/empresa.dart';
import 'package:guardaya_app/domain/repositories/empresas_repository.dart';

class CrearEmpresa implements UseCase<Empresa, CrearEmpresaParams> {
  final EmpresasRepository repository;
  CrearEmpresa(this.repository);

  @override
  Future<Either<Failure, Empresa>> call(CrearEmpresaParams params) async {
    return await repository.crearEmpresa(params.empresa);
  }
}

class CrearEmpresaParams {
  final Empresa empresa;
  CrearEmpresaParams({required this.empresa});
}
