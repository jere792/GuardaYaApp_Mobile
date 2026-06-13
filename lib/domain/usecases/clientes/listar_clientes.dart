import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/cliente.dart';
import 'package:guardaya_app/domain/repositories/clientes_repository.dart';

class ListarClientes implements UseCase<List<Cliente>, ListarClientesParams> {
  final ClientesRepository repository;
  ListarClientes(this.repository);

  @override
  Future<Either<Failure, List<Cliente>>> call(ListarClientesParams params) async {
    return await repository.listarClientes(params.empresaId);
  }
}

class ListarClientesParams {
  final String empresaId;
  ListarClientesParams({required this.empresaId});
}