import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';

class ObtenerVentasPorFecha implements UseCase<List<Venta>, ObtenerVentasParams> {
  final VentasRepository repository;
  ObtenerVentasPorFecha(this.repository);

  @override
  Future<Either<Failure, List<Venta>>> call(ObtenerVentasParams params) async {
    return await repository.obtenerVentasPorFecha(params.empresaId, params.fecha);
  }
}

class ObtenerVentasParams {
  final String empresaId;
  final DateTime fecha;
  ObtenerVentasParams({required this.empresaId, required this.fecha});
}
