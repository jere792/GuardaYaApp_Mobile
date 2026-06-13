import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/cliente.dart';
import 'package:guardaya_app/domain/repositories/clientes_repository.dart';

class ActualizarCliente implements UseCase<Cliente, ActualizarClienteParams> {
  final ClientesRepository repository;
  ActualizarCliente(this.repository);

  @override
  Future<Either<Failure, Cliente>> call(ActualizarClienteParams params) async {
    return await repository.actualizarCliente(params.cliente);
  }
}

class ActualizarClienteParams {
  final Cliente cliente;
  ActualizarClienteParams({required this.cliente});
}