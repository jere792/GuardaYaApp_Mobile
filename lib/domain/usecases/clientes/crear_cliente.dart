import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/cliente.dart';
import 'package:guardaya_app/domain/repositories/clientes_repository.dart';

class CrearClienteUsecase implements UseCase<Cliente, CrearClienteParams> {
  final ClientesRepository repository;
  CrearClienteUsecase(this.repository);

  @override
  Future<Either<Failure, Cliente>> call(CrearClienteParams params) async {
    return await repository.crearCliente(params.cliente);
  }
}

class CrearClienteParams {
  final Cliente cliente;
  CrearClienteParams({required this.cliente});
}