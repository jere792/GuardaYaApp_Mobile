import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/data/datasources/remote/categorias_datasource.dart';
import 'package:guardaya_app/data/models/categoria_model.dart';
import 'package:guardaya_app/domain/entities/categoria.dart';
import 'package:guardaya_app/domain/repositories/categorias_repository.dart';

class CategoriasRepositoryImpl implements CategoriasRepository {
  final CategoriasDatasource _datasource;

  CategoriasRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<Categoria>>> listarCategorias(String empresaId) async {
    try {
      final list = await _datasource.listarCategorias(empresaId);
      final categorias = list
          .map((json) => CategoriaModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      return Right(categorias);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Categoria>> crearCategoria(Categoria categoria) async {
    try {
      final model = CategoriaModel(
        id: '',
        empresaId: categoria.empresaId,
        nombre: categoria.nombre,
        descripcion: categoria.descripcion,
        activo: true,
        createdAt: DateTime.now(),
      );
      final data = await _datasource.crearCategoria(model.toInsertJson());
      return Right(CategoriaModel.fromJson(data).toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Categoria>> actualizarCategoria(Categoria categoria) async {
    try {
      final model = CategoriaModel(
        id: categoria.id,
        empresaId: categoria.empresaId,
        nombre: categoria.nombre,
        descripcion: categoria.descripcion,
        activo: categoria.activo,
        createdAt: categoria.createdAt,
      );
      final data = await _datasource.actualizarCategoria(categoria.id, model.toUpdateJson());
      return Right(CategoriaModel.fromJson(data).toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> desactivarCategoria(String categoriaId) async {
    try {
      await _datasource.desactivarCategoria(categoriaId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}