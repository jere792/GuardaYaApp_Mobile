import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';

class ActualizarVenta implements UseCase<Venta, ActualizarVentaParams> {
  final VentasRepository repository;
  ActualizarVenta(this.repository);

  @override
  Future<Either<Failure, Venta>> call(ActualizarVentaParams params) async {
    return await repository.actualizarVenta(params.venta);
  }
}

class ActualizarVentaParams {
  final Venta venta;
  ActualizarVentaParams({required this.venta});
}
