import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/domain/entities/venta.dart';

abstract class VentasRepository {
  Future<Either<Failure, Venta>> registrarVenta(Venta venta);
  Future<Either<Failure, List<Venta>>> obtenerVentasPorFecha(String empresaId, DateTime fecha);
  Future<Either<Failure, List<Venta>>> buscarVentaPorCodigo(String empresaId, String codigo);
  Future<Either<Failure, List<Venta>>> buscarVentaPorTelefono(String empresaId, String telefono);
  Future<Either<Failure, List<Venta>>> buscarVentaPorNombre(String empresaId, String nombre);
  Future<Either<Failure, List<Venta>>> obtenerVentasPorRango(String empresaId, DateTime desde, DateTime hasta);
  Future<Either<Failure, Venta>> obtenerVentaPorId(String ventaId);
  Future<Either<Failure, Venta>> actualizarVenta(Venta venta);
  Future<Either<Failure, void>> cambiarEstadoVenta(String ventaId, String nuevoEstado);
  Future<Either<Failure, List<Venta>>> obtenerVentasPendientesSync();
  Future<Either<Failure, void>> syncVentasPendientes();
}
