import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/domain/entities/categoria.dart';

abstract class CategoriasRepository {
  Future<Either<Failure, List<Categoria>>> listarCategorias(String empresaId);
  Future<Either<Failure, Categoria>> crearCategoria(Categoria categoria);
  Future<Either<Failure, Categoria>> actualizarCategoria(Categoria categoria);
  Future<Either<Failure, void>> desactivarCategoria(String categoriaId);
}