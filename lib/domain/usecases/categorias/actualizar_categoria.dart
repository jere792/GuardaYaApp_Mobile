import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/categoria.dart';
import 'package:guardaya_app/domain/repositories/categorias_repository.dart';

class ActualizarCategoria implements UseCase<Categoria, ActualizarCategoriaParams> {
  final CategoriasRepository repository;
  ActualizarCategoria(this.repository);

  @override
  Future<Either<Failure, Categoria>> call(ActualizarCategoriaParams params) async {
    return await repository.actualizarCategoria(params.categoria);
  }
}

class ActualizarCategoriaParams {
  final Categoria categoria;
  ActualizarCategoriaParams({required this.categoria});
}