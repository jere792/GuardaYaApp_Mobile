import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/domain/entities/producto.dart';

abstract class ProductosRepository {
  Future<Either<Failure, List<Producto>>> listarProductos(String empresaId);
  Future<Either<Failure, Producto>> crearProducto(Producto producto);
  Future<Either<Failure, Producto>> actualizarProducto(Producto producto);
  Future<Either<Failure, void>> desactivarProducto(String productoId);
  Future<Either<Failure, void>> reactivarProducto(String productoId);
}
