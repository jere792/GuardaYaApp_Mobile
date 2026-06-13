import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/entities/categoria.dart';
import 'package:guardaya_app/domain/repositories/categorias_repository.dart';

class ListarCategorias implements UseCase<List<Categoria>, ListarCategoriasParams> {
  final CategoriasRepository repository;
  ListarCategorias(this.repository);

  @override
  Future<Either<Failure, List<Categoria>>> call(ListarCategoriasParams params) async {
    return await repository.listarCategorias(params.empresaId);
  }
}

class ListarCategoriasParams {
  final String empresaId;
  ListarCategoriasParams({required this.empresaId});
}