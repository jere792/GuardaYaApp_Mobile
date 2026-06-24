import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';

class BuscarVentaPorNombre implements UseCase<List<Venta>, BuscarVentaPorNombreParams> {
  final VentasRepository repository;
  BuscarVentaPorNombre(this.repository);

  @override
  Future<Either<Failure, List<Venta>>> call(BuscarVentaPorNombreParams params) async {
    return await repository.buscarVentaPorNombre(params.empresaId, params.nombre);
  }
}

class BuscarVentaPorNombreParams {
  final String empresaId;
  final String nombre;
  BuscarVentaPorNombreParams({required this.empresaId, required this.nombre});
}
