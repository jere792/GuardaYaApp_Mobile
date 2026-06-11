import 'package:fpdart/fpdart.dart';
import 'package:guardaya_app/core/errors/exceptions.dart';
import 'package:guardaya_app/core/errors/failures.dart';
import 'package:guardaya_app/data/datasources/local/db/pending_ventas_dao.dart';
import 'package:guardaya_app/data/datasources/remote/ventas_datasource.dart';
import 'package:guardaya_app/data/models/pending_venta_model.dart';
import 'package:guardaya_app/data/models/venta_model.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';
import 'package:guardaya_app/services/connectivity_service.dart';

class VentasRepositoryImpl implements VentasRepository {
  final VentasDatasource _remote;
  final PendingVentasDao _local;
  final ConnectivityService _connectivity;

  VentasRepositoryImpl(this._remote, this._local, this._connectivity);

  @override
  Future<Either<Failure, Venta>> registrarVenta(Venta venta) async {
    try {
      if (await _connectivity.isOnline) {
        final model = VentaModel.fromEntity(venta);
        final data = await _remote.registrarVenta(model.toJson());
        return Right(VentaModel.fromJson(data).toEntity());
      } else {
        final pending = PendingVentaModel(
          id: venta.id,
          empresaId: venta.empresaId,
          usuarioId: venta.usuarioId,
          clienteId: venta.clienteId,
          codigoYape: venta.codigoYape,
          monto: venta.monto,
          clienteNombre: venta.clienteNombre,
          clienteTelefono: venta.clienteTelefono,
          fechaYape: venta.fechaYape?.toIso8601String(),
          descripcion: venta.descripcion,
          estado: venta.estado,
          createdAt: venta.createdAt.toIso8601String(),
        );
        await _local.insertPendingVenta(pending);
        return Right(venta);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Venta>>> obtenerVentasPorFecha(String empresaId, DateTime fecha) async {
    try {
      final data = await _remote.obtenerVentasPorFecha(empresaId, fecha);
      return Right(data.map((e) => VentaModel.fromJson(e).toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Venta?>> buscarVentaPorCodigo(String empresaId, String codigo) async {
    try {
      final data = await _remote.buscarVentaPorCodigo(empresaId, codigo);
      if (data == null) return const Right(null);
      return Right(VentaModel.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Venta>>> buscarVentaPorTelefono(String empresaId, String telefono) async {
    try {
      final data = await _remote.buscarVentaPorTelefono(empresaId, telefono);
      return Right(data.map((e) => VentaModel.fromJson(e).toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Venta>>> buscarVentaPorNombre(String empresaId, String nombre) async {
    // TODO: Implementar busqueda por nombre en Supabase
    return Left(ServerFailure('No implementado'));
  }

  @override
  Future<Either<Failure, void>> cambiarEstadoVenta(String ventaId, String nuevoEstado) async {
    try {
      await _remote.cambiarEstadoVenta(ventaId, nuevoEstado);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Venta>>> obtenerVentasPendientesSync() async {
    try {
      final pending = await _local.getPendingVentas();
      return Right(pending.map((p) => Venta(
        id: p.id,
        empresaId: p.empresaId,
        usuarioId: p.usuarioId,
        clienteId: p.clienteId,
        codigoYape: p.codigoYape,
        monto: p.monto,
        clienteNombre: p.clienteNombre,
        clienteTelefono: p.clienteTelefono,
        fechaYape: p.fechaYape != null ? DateTime.tryParse(p.fechaYape!) : null,
        descripcion: p.descripcion,
        estado: p.estado,
        createdAt: DateTime.tryParse(p.createdAt) ?? DateTime.now(),
      )).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncVentasPendientes() async {
    try {
      if (await _connectivity.isOffline) {
        return Left(NoInternetFailure());
      }
      
      final pending = await _local.getPendingVentas();
      for (final p in pending) {
        try {
          final model = VentaModel(
            id: p.id,
            empresaId: p.empresaId,
            usuarioId: p.usuarioId,
            clienteId: p.clienteId,
            codigoYape: p.codigoYape,
            monto: p.monto,
            clienteNombre: p.clienteNombre,
            clienteTelefono: p.clienteTelefono,
            fechaYape: p.fechaYape != null ? DateTime.tryParse(p.fechaYape!) : null,
            descripcion: p.descripcion,
            estado: p.estado,
            createdAt: DateTime.tryParse(p.createdAt) ?? DateTime.now(),
          );
          await _remote.registrarVenta(model.toJson());
          await _local.deletePendingVenta(p.id);
        } catch (e) {
          await _local.updateSyncStatus(p.id, 'error', error: e.toString(), retryCount: p.retryCount + 1);
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
