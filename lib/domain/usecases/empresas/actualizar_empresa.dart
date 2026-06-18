import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/empresa.dart';
import 'package:guardaya_app/domain/repositories/empresas_repository.dart';

class ActualizarEmpresa implements UseCase<Empresa, ActualizarEmpresaParams> {
  final EmpresasRepository repository;
  ActualizarEmpresa(this.repository);

  @override
  Future<Either<Failure, Empresa>> call(ActualizarEmpresaParams params) async {
    return await repository.actualizarEmpresa(params.empresa);
  }
}

class ActualizarEmpresaParams {
  final Empresa empresa;
  ActualizarEmpresaParams({required this.empresa});
}
