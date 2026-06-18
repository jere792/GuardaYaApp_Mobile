import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/producto.dart';
import 'package:guardaya_app/domain/repositories/productos_repository.dart';

class CrearProducto implements UseCase<Producto, CrearProductoParams> {
  final ProductosRepository repository;
  CrearProducto(this.repository);

  @override
  Future<Either<Failure, Producto>> call(CrearProductoParams params) async {
    return await repository.crearProducto(params.producto);
  }
}

class CrearProductoParams {
  final Producto producto;
  CrearProductoParams({required this.producto});
}
