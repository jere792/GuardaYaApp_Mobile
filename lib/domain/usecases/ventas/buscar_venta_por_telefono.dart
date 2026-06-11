import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';

class BuscarVentaPorTelefono implements UseCase<List<Venta>, BuscarVentaPorTelefonoParams> {
  final VentasRepository repository;
  BuscarVentaPorTelefono(this.repository);

  @override
  Future<Either<Failure, List<Venta>>> call(BuscarVentaPorTelefonoParams params) async {
    return await repository.buscarVentaPorTelefono(params.empresaId, params.telefono);
  }
}

class BuscarVentaPorTelefonoParams {
  final String empresaId;
  final String telefono;
  BuscarVentaPorTelefonoParams({required this.empresaId, required this.telefono});
}
