import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/data/datasources/remote/productos_datasource.dart';
import 'package:guardaya_app/data/models/producto_model.dart';
import 'package:guardaya_app/domain/entities/producto.dart';
import 'package:guardaya_app/domain/repositories/productos_repository.dart';

class ProductosRepositoryImpl implements ProductosRepository {
  final ProductosDatasource _datasource;

  ProductosRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<Producto>>> listarProductos(String empresaId) async {
    try {
      final list = await _datasource.listarProductos(empresaId);
      final productos = list
          .map((json) => ProductoModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Right(productos);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Producto>> crearProducto(Producto producto) async {
    try {
      final model = ProductoModel(
        id: '',
        empresaId: producto.empresaId,
        categoriaId: producto.categoriaId,
        nombre: producto.nombre,
        descripcion: producto.descripcion,
        precio: producto.precio,
        activo: true,
        createdAt: DateTime.now(),
      );
      final data = await _datasource.crearProducto(model.toInsertJson());
      return Right(ProductoModel.fromJson(data).toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Producto>> actualizarProducto(Producto producto) async {
    try {
      final model = ProductoModel(
        id: producto.id,
        empresaId: producto.empresaId,
        categoriaId: producto.categoriaId,
        nombre: producto.nombre,
        descripcion: producto.descripcion,
        precio: producto.precio,
        activo: producto.activo,
        createdAt: producto.createdAt,
      );
      final data = await _datasource.actualizarProducto(producto.id, model.toUpdateJson());
      return Right(ProductoModel.fromJson(data).toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> desactivarProducto(String productoId) async {
    try {
      await _datasource.desactivarProducto(productoId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reactivarProducto(String productoId) async {
    try {
      await _datasource.reactivarProducto(productoId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
