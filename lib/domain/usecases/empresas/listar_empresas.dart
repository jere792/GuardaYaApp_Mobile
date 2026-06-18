import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/empresa.dart';
import 'package:guardaya_app/domain/repositories/empresas_repository.dart';

class ListarEmpresas implements UseCase<List<Empresa>, NoParams> {
  final EmpresasRepository repository;
  ListarEmpresas(this.repository);

  @override
  Future<Either<Failure, List<Empresa>>> call(NoParams params) async {
    return await repository.listarEmpresas();
  }
}
