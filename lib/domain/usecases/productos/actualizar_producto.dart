import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/producto.dart';
import 'package:guardaya_app/domain/repositories/productos_repository.dart';

class ActualizarProducto implements UseCase<Producto, ActualizarProductoParams> {
  final ProductosRepository repository;
  ActualizarProducto(this.repository);

  @override
  Future<Either<Failure, Producto>> call(ActualizarProductoParams params) async {
    return await repository.actualizarProducto(params.producto);
  }
}

class ActualizarProductoParams {
  final Producto producto;
  ActualizarProductoParams({required this.producto});
}
