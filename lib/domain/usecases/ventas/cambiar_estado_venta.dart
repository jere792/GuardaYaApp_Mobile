import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';

class CambiarEstadoVenta implements UseCase<void, CambiarEstadoParams> {
  final VentasRepository repository;
  CambiarEstadoVenta(this.repository);

  @override
  Future<<Either<Failure, void>> call(CambiarEstadoParams params) async {
    return await repository.cambiarEstadoVenta(params.ventaId, params.nuevoEstado);
  }
}

class CambiarEstadoParams {
  final String ventaId;
  final String nuevoEstado;
  CambiarEstadoParams({required this.ventaId, required this.nuevoEstado});
}