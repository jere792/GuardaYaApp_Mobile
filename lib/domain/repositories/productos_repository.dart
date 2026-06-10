import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/domain/entities/producto.dart';

abstract class ProductosRepository {
  Future<<Either<Failure, List<Producto>>> obtenerProductos(String empresaId);
  Future<<Either<Failure, Producto?>> obtenerProductoPorId(String id);
}