import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/repositories/clientes_repository.dart';

class DesactivarCliente implements UseCase<void, DesactivarClienteParams> {
  final ClientesRepository repository;
  DesactivarCliente(this.repository);

  @override
  Future<Either<Failure, void>> call(DesactivarClienteParams params) async {
    return await repository.desactivarCliente(params.clienteId, reactivar: params.reactivar);
  }
}

class DesactivarClienteParams {
  final String clienteId;
  final bool reactivar;
  DesactivarClienteParams({required this.clienteId, this.reactivar = false});
}