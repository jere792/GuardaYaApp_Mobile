import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/producto.dart';
import 'package:guardaya_app/domain/repositories/productos_repository.dart';

class ListarProductos implements UseCase<List<Producto>, ListarProductosParams> {
  final ProductosRepository repository;
  ListarProductos(this.repository);

  @override
  Future<Either<Failure, List<Producto>>> call(ListarProductosParams params) async {
    return await repository.listarProductos(params.empresaId);
  }
}

class ListarProductosParams {
  final String empresaId;
  ListarProductosParams({required this.empresaId});
}
