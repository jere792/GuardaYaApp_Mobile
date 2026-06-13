import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/categoria.dart';
import 'package:guardaya_app/domain/repositories/categorias_repository.dart';

class CrearCategoria implements UseCase<Categoria, CrearCategoriaParams> {
  final CategoriasRepository repository;
  CrearCategoria(this.repository);

  @override
  Future<Either<Failure, Categoria>> call(CrearCategoriaParams params) async {
    return await repository.crearCategoria(params.categoria);
  }
}

class CrearCategoriaParams {
  final Categoria categoria;
  CrearCategoriaParams({required this.categoria});
}