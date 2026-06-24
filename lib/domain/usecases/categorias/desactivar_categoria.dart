import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/core/usecases/usecase.dart';
import 'package:guardaya_app/domain/repositories/categorias_repository.dart';

class DesactivarCategoria implements UseCase<void, DesactivarCategoriaParams> {
  final CategoriasRepository repository;
  DesactivarCategoria(this.repository);

  @override
  Future<Either<Failure, void>> call(DesactivarCategoriaParams params) async {
    return await repository.desactivarCategoria(params.categoriaId, reactivar: params.reactivar);
  }
}

class DesactivarCategoriaParams {
  final String categoriaId;
  final bool reactivar;
  DesactivarCategoriaParams({required this.categoriaId, this.reactivar = false});
}