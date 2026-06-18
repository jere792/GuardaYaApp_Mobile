import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/repositories/productos_repository.dart';

class DesactivarProducto implements UseCase<void, DesactivarProductoParams> {
  final ProductosRepository repository;
  DesactivarProducto(this.repository);

  @override
  Future<Either<Failure, void>> call(DesactivarProductoParams params) async {
    if (params.reactivar) {
      return await repository.reactivarProducto(params.productoId);
    }
    return await repository.desactivarProducto(params.productoId);
  }
}

class DesactivarProductoParams {
  final String productoId;
  final bool reactivar;
  DesactivarProductoParams({required this.productoId, this.reactivar = false});
}
