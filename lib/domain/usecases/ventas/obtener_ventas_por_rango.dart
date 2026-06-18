import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';

class ObtenerVentasPorRango implements UseCase<List<Venta>, ObtenerVentasPorRangoParams> {
  final VentasRepository repository;
  ObtenerVentasPorRango(this.repository);

  @override
  Future<Either<Failure, List<Venta>>> call(ObtenerVentasPorRangoParams params) async {
    return await repository.obtenerVentasPorRango(params.empresaId, params.desde, params.hasta);
  }
}

class ObtenerVentasPorRangoParams {
  final String empresaId;
  final DateTime desde;
  final DateTime hasta;
  ObtenerVentasPorRangoParams({required this.empresaId, required this.desde, required this.hasta});
}
