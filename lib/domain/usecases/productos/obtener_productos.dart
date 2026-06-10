import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/producto.dart';
import 'package:guardaya_app/domain/repositories/productos_repository.dart';

class ObtenerProductos implements UseCase<List<Producto>, String> {
  final ProductosRepository repository;
  ObtenerProductos(this.repository);

  @override
  Future<<Either<Failure, List<Producto>>> call(String empresaId) async {
    return await repository.obtenerProductos(empresaId);
  }
}