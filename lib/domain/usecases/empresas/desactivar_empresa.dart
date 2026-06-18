import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/repositories/empresas_repository.dart';

class DesactivarEmpresa implements UseCase<void, DesactivarEmpresaParams> {
  final EmpresasRepository repository;
  DesactivarEmpresa(this.repository);

  @override
  Future<Either<Failure, void>> call(DesactivarEmpresaParams params) async {
    return await repository.desactivarEmpresa(params.empresaId, reactivar: params.reactivar);
  }
}

class DesactivarEmpresaParams {
  final String empresaId;
  final bool reactivar;
  DesactivarEmpresaParams({required this.empresaId, this.reactivar = false});
}
