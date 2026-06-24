import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';

class BuscarVentaPorCodigo implements UseCase<List<Venta>, BuscarVentaPorCodigoParams> {
  final VentasRepository repository;
  BuscarVentaPorCodigo(this.repository);

  @override
  Future<Either<Failure, List<Venta>>> call(BuscarVentaPorCodigoParams params) async {
    return await repository.buscarVentaPorCodigo(params.empresaId, params.codigo);
  }
}

class BuscarVentaPorCodigoParams {
  final String empresaId;
  final String codigo;
  BuscarVentaPorCodigoParams({required this.empresaId, required this.codigo});
}
