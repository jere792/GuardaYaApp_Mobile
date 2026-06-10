import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';

class RegistrarVenta implements UseCase<Venta, Venta> {
  final VentasRepository repository;
  RegistrarVenta(this.repository);

  @override
  Future<<Either<Failure, Venta>> call(Venta params) async {
    return await repository.registrarVenta(params);
  }
}