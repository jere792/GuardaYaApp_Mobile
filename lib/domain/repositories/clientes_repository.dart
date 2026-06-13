import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/domain/entities/cliente.dart';

abstract class ClientesRepository {
  Future<Either<Failure, List<Cliente>>> listarClientes(String empresaId);
  Future<Either<Failure, List<Cliente>>> obtenerClientes(String empresaId);
  Future<Either<Failure, Cliente?>> buscarClientePorTelefono(String empresaId, String telefono);
  Future<Either<Failure, Cliente>> crearCliente(Cliente cliente);
  Future<Either<Failure, Cliente>> actualizarCliente(Cliente cliente);
  Future<Either<Failure, void>> desactivarCliente(String clienteId);
}
