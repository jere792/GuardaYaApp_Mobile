import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/data/datasources/remote/productos_datasource.dart';
import 'package:guardaya_app/data/models/producto_model.dart';
import 'package:guardaya_app/domain/entities/producto.dart';
import 'package:guardaya_app/domain/repositories/productos_repository.dart';

class ProductosRepositoryImpl implements ProductosRepository {
  final ProductosDatasource _datasource;

  ProductosRepositoryImpl(this._datasource);

  @override
  Future<<Either<Failure, List<Producto>>> obtenerProductos(String empresaId) async {
    try {
      final data = await _datasource.obtenerProductos(empresaId);
      return Right(data.map((e) => ProductoModel.fromJson(e).toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<<Either<Failure, Producto?>> obtenerProductoPorId(String id) async {
    try {
      final data = await _datasource.obtenerProductoPorId(id);
      if (data == null) return const Right(null);
      return Right(ProductoModel.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}