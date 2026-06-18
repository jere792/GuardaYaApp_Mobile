import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';

class ObtenerVentaPorId implements UseCase<Venta, String> {
  final VentasRepository repository;
  ObtenerVentaPorId(this.repository);

  @override
  Future<Either<Failure, Venta>> call(String ventaId) async {
    return await repository.obtenerVentaPorId(ventaId);
  }
}
