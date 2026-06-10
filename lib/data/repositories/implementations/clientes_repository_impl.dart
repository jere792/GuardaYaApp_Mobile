import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/data/datasources/remote/clientes_datasource.dart';
import 'package:guardaya_app/data/models/cliente_model.dart';
import 'package:guardaya_app/domain/entities/cliente.dart';
import 'package:guardaya_app/domain/repositories/clientes_repository.dart';

class ClientesRepositoryImpl implements ClientesRepository {
  final ClientesDatasource _datasource;

  ClientesRepositoryImpl(this._datasource);

  @override
  Future<<Either<Failure, List<Cliente>>> obtenerClientes(String empresaId) async {
    try {
      final data = await _datasource.obtenerClientes(empresaId);
      return Right(data.map((e) => ClienteModel.fromJson(e).toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<<Either<Failure, Cliente?>> buscarClientePorTelefono(String empresaId, String telefono) async {
    try {
      final data = await _datasource.buscarClientePorTelefono(empresaId, telefono);
      if (data == null) return const Right(null);
      return Right(ClienteModel.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<<Either<Failure, Cliente>> crearCliente(Cliente cliente) async {
    try {
      final model = ClienteModel(
        id: cliente.id,
        empresaId: cliente.empresaId,
        nombre: cliente.nombre,
        telefono: cliente.telefono,
        email: cliente.email,
        direccion: cliente.direccion,
        notas: cliente.notas,
        activo: cliente.activo,
        createdAt: cliente.createdAt,
      );
      final data = await _datasource.crearCliente(model.toJson());
      return Right(ClienteModel.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}