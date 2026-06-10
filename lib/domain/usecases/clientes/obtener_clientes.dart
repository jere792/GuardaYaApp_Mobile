import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/cliente.dart';
import 'package:guardaya_app/domain/repositories/clientes_repository.dart';

class ObtenerClientes implements UseCase<List<Cliente>, String> {
  final ClientesRepository repository;
  ObtenerClientes(this.repository);

  @override
  Future<<Either<Failure, List<Cliente>>> call(String empresaId) async {
    return await repository.obtenerClientes(empresaId);
  }
}