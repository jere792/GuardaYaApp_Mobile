import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardaya_app/data/datasources/local/db/pending_ventas_dao.dart';
import 'package:guardaya_app/data/models/pending_venta_model.dart';
import 'package:guardaya_app/data/datasources/remote/ventas_datasource.dart';
import 'package:guardaya_app/data/repositories/implementations/ventas_repository_impl.dart';
import 'package:guardaya_app/domain/entities/tipo_transferencia.dart';
import 'package:guardaya_app/domain/entities/venta.dart';
import 'package:guardaya_app/domain/repositories/ventas_repository.dart';
import 'package:guardaya_app/domain/usecases/ventas/buscar_venta_por_codigo.dart';
import 'package:guardaya_app/domain/usecases/ventas/buscar_venta_por_nombre.dart';
import 'package:guardaya_app/domain/usecases/ventas/buscar_venta_por_telefono.dart';
import 'package:guardaya_app/domain/usecases/ventas/cambiar_estado_venta.dart';
import 'package:guardaya_app/domain/usecases/ventas/obtener_venta_por_id.dart';
import 'package:guardaya_app/domain/usecases/ventas/obtener_ventas_por_fecha.dart';
import 'package:guardaya_app/domain/usecases/ventas/obtener_ventas_por_rango.dart';
import 'package:guardaya_app/domain/usecases/ventas/actualizar_venta.dart';
import 'package:guardaya_app/domain/usecases/ventas/registrar_venta.dart';
import 'package:guardaya_app/services/connectivity_service.dart';
import 'package:guardaya_app/services/supabase_service.dart';

final tiposTransferenciaProvider = FutureProvider<List<TipoTransferencia>>((ref) async {
  final response = await SupabaseService.from('tipos_transferencia')
      .select()
      .eq('activo', true)
      .order('nombre', ascending: true);
  return (response as List).map((e) => TipoTransferencia.fromJson(e as Map<String, dynamic>)).toList();
});

final ventasProvider = StateNotifierProvider<VentasNotifier, VentasState>((ref) {
  return VentasNotifier(
    registrar: ref.watch(registrarVentaProvider),
    actualizar: ref.watch(actualizarVentaProvider),
    obtenerPorFecha: ref.watch(obtenerVentasPorFechaProvider),
    buscarPorCodigo: ref.watch(buscarPorCodigoProvider),
    buscarPorTelefono: ref.watch(buscarPorTelefonoProvider),
    buscarPorNombre: ref.watch(buscarPorNombreProvider),
    cambiarEstado: ref.watch(cambiarEstadoVentaProvider),
    obtenerPorId: ref.watch(obtenerVentaPorIdProvider),
    obtenerPorRango: ref.watch(obtenerVentasPorRangoProvider),
    pendingDao: ref.watch(pendingVentasDaoProvider),
  );
});

// Providers de dependencias
final ventasDatasourceProvider = Provider<VentasDatasource>((ref) => VentasDatasource());
final pendingVentasDaoProvider = Provider<PendingVentasDao>((ref) => PendingVentasDao());
final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());

final ventasRepositoryProvider = Provider<VentasRepository>((ref) {
  return VentasRepositoryImpl(
    ref.watch(ventasDatasourceProvider),
    ref.watch(pendingVentasDaoProvider),
    ref.watch(connectivityServiceProvider),
  );
});

// Providers de usecases
final registrarVentaProvider = Provider<RegistrarVenta>((ref) {
  return RegistrarVenta(ref.watch(ventasRepositoryProvider));
});

final actualizarVentaProvider = Provider<ActualizarVenta>((ref) {
  return ActualizarVenta(ref.watch(ventasRepositoryProvider));
});

final obtenerVentasPorFechaProvider = Provider<ObtenerVentasPorFecha>((ref) {
  return ObtenerVentasPorFecha(ref.watch(ventasRepositoryProvider));
});

final buscarPorCodigoProvider = Provider<BuscarVentaPorCodigo>((ref) {
  return BuscarVentaPorCodigo(ref.watch(ventasRepositoryProvider));
});

final buscarPorTelefonoProvider = Provider<BuscarVentaPorTelefono>((ref) {
  return BuscarVentaPorTelefono(ref.watch(ventasRepositoryProvider));
});

final buscarPorNombreProvider = Provider<BuscarVentaPorNombre>((ref) {
  return BuscarVentaPorNombre(ref.watch(ventasRepositoryProvider));
});

final cambiarEstadoVentaProvider = Provider<CambiarEstadoVenta>((ref) {
  return CambiarEstadoVenta(ref.watch(ventasRepositoryProvider));
});

final obtenerVentaPorIdProvider = Provider<ObtenerVentaPorId>((ref) {
  return ObtenerVentaPorId(ref.watch(ventasRepositoryProvider));
});

final obtenerVentasPorRangoProvider = Provider<ObtenerVentasPorRango>((ref) {
  return ObtenerVentasPorRango(ref.watch(ventasRepositoryProvider));
});

class VentasState {
  final List<Venta> ventas;
  final Venta? ventaSeleccionada;
  final bool isLoading;
  final String? error;
  final bool showOfflineMessage;

  const VentasState({
    this.ventas = const [],
    this.ventaSeleccionada,
    this.isLoading = false,
    this.error,
    this.showOfflineMessage = false,
  });

  VentasState copyWith({
    List<Venta>? ventas,
    Venta? ventaSeleccionada,
    bool? isLoading,
    String? error,
    bool? showOfflineMessage,
  }) {
    return VentasState(
      ventas: ventas ?? this.ventas,
      ventaSeleccionada: ventaSeleccionada ?? this.ventaSeleccionada,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      showOfflineMessage: showOfflineMessage ?? this.showOfflineMessage,
    );
  }
}

class VentasNotifier extends StateNotifier<VentasState> {
  final RegistrarVenta _registrar;
  final ActualizarVenta _actualizar;
  final ObtenerVentasPorFecha _obtenerPorFecha;
  final BuscarVentaPorCodigo _buscarPorCodigo;
  final BuscarVentaPorTelefono _buscarPorTelefono;
  final BuscarVentaPorNombre _buscarPorNombre;
  final CambiarEstadoVenta _cambiarEstado;
  final ObtenerVentaPorId _obtenerPorId;
  final ObtenerVentasPorRango _obtenerPorRango;
  final PendingVentasDao _pendingDao;

  VentasNotifier({
    required RegistrarVenta registrar,
    required ActualizarVenta actualizar,
    required ObtenerVentasPorFecha obtenerPorFecha,
    required BuscarVentaPorCodigo buscarPorCodigo,
    required BuscarVentaPorTelefono buscarPorTelefono,
    required BuscarVentaPorNombre buscarPorNombre,
    required CambiarEstadoVenta cambiarEstado,
    required ObtenerVentaPorId obtenerPorId,
    required ObtenerVentasPorRango obtenerPorRango,
    required PendingVentasDao pendingDao,
  })  : _registrar = registrar,
        _actualizar = actualizar,
        _obtenerPorFecha = obtenerPorFecha,
        _buscarPorCodigo = buscarPorCodigo,
        _buscarPorTelefono = buscarPorTelefono,
        _buscarPorNombre = buscarPorNombre,
        _cambiarEstado = cambiarEstado,
        _obtenerPorId = obtenerPorId,
        _obtenerPorRango = obtenerPorRango,
        _pendingDao = pendingDao,
        super(const VentasState());

  Future<void> obtenerVentaPorId(String ventaId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _obtenerPorId(ventaId);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (venta) => state = state.copyWith(isLoading: false, ventaSeleccionada: venta),
    );
  }

  Future<void> registrarVenta(Venta venta) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _registrar(venta);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (venta) => state = state.copyWith(isLoading: false, ventas: [...state.ventas, venta]),
    );
  }

  Future<void> actualizarVenta(Venta venta) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _actualizar(ActualizarVentaParams(venta: venta));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (ventaActualizada) {
        state = state.copyWith(isLoading: false, ventaSeleccionada: ventaActualizada);
        final updatedList = state.ventas.map((v) => v.id == ventaActualizada.id ? ventaActualizada : v).toList();
        state = state.copyWith(ventas: updatedList);
      },
    );
  }

  Future<void> obtenerVentasDelDia(String empresaId, DateTime fecha) async {
    state = state.copyWith(isLoading: true, error: null, showOfflineMessage: false);
    final result = await _obtenerPorFecha(ObtenerVentasParams(empresaId: empresaId, fecha: fecha));

    List<Venta>? remoteVentas;
    String? errorMsg;

    result.fold(
      (failure) {
        errorMsg = failure.message;
      },
      (ventas) {
        remoteVentas = ventas;
      },
    );

    final pending = await _pendingDao.getPendingVentas();
    final pendingVentas = pending.map((p) => _pendingToVenta(p)).toList();

    if (errorMsg != null) {
      final map = <String, Venta>{};
      for (final v in pendingVentas) {
        map[v.id] = v;
      }
      state = state.copyWith(
        isLoading: false,
        ventas: map.values.toList(),
        showOfflineMessage: true,
      );
    } else {
      final map = <String, Venta>{};
      for (final v in remoteVentas!) {
        map[v.id] = v;
      }
      for (final v in pendingVentas) {
        if (!map.containsKey(v.id)) {
          map[v.id] = v;
        }
      }
      state = state.copyWith(isLoading: false, ventas: map.values.toList());
    }
  }

  Future<void> buscarPorCodigo(String empresaId, String codigo) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _buscarPorCodigo(BuscarVentaPorCodigoParams(empresaId: empresaId, codigo: codigo));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (ventas) => state = state.copyWith(isLoading: false, ventas: ventas),
    );
  }

  Future<void> buscarPorTelefono(String empresaId, String telefono) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _buscarPorTelefono(BuscarVentaPorTelefonoParams(empresaId: empresaId, telefono: telefono));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (ventas) => state = state.copyWith(isLoading: false, ventas: ventas),
    );
  }

  Future<void> buscarVentas({
    required String empresaId,
    String? codigo,
    String? telefono,
    String? nombre,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<Venta> resultados = [];

      if (codigo != null && codigo.isNotEmpty) {
        final result = await _buscarPorCodigo(BuscarVentaPorCodigoParams(empresaId: empresaId, codigo: codigo));
        result.fold(
          (failure) => state = state.copyWith(isLoading: false, error: 'Error al buscar. Verifica tu conexión a internet.'),
          (ventas) => resultados = ventas,
        );
        if (state.error != null) return;
        final pending = await _pendingDao.getPendingVentas();
        for (final p in pending) {
          if (p.codigoYape?.contains(codigo) ?? false) {
            resultados.add(_pendingToVenta(p));
          }
        }
      } else if (telefono != null && telefono.isNotEmpty) {
        final result = await _buscarPorTelefono(BuscarVentaPorTelefonoParams(empresaId: empresaId, telefono: telefono));
        result.fold(
          (failure) => state = state.copyWith(isLoading: false, error: 'Error al buscar. Verifica tu conexión a internet.'),
          (ventas) => resultados = ventas,
        );
        if (state.error != null) return;
        final pending = await _pendingDao.getPendingVentas();
        for (final p in pending) {
          if (p.clienteTelefono?.toLowerCase().contains(telefono.toLowerCase()) ?? false) {
            resultados.add(_pendingToVenta(p));
          }
        }
      } else if (nombre != null && nombre.isNotEmpty) {
        final result = await _buscarPorNombre(BuscarVentaPorNombreParams(empresaId: empresaId, nombre: nombre));
        result.fold(
          (failure) => state = state.copyWith(isLoading: false, error: 'Error al buscar. Verifica tu conexión a internet.'),
          (ventas) => resultados = ventas,
        );
        if (state.error != null) return;
        final pending = await _pendingDao.getPendingVentas();
        for (final p in pending) {
          if (p.clienteNombre?.toLowerCase().contains(nombre.toLowerCase()) ?? false) {
            resultados.add(_pendingToVenta(p));
          }
        }
      } else {
        final inicio = fechaInicio ?? DateTime.now();
        final fin = fechaFin ?? inicio;
        if (inicio == fin) {
          final result = await _obtenerPorFecha(ObtenerVentasParams(empresaId: empresaId, fecha: inicio));
          result.fold(
            (failure) => {},
            (ventas) => resultados = ventas,
          );
        } else {
          final result = await _obtenerPorRango(ObtenerVentasPorRangoParams(empresaId: empresaId, desde: inicio, hasta: fin));
          result.fold(
            (failure) => {},
            (ventas) => resultados = ventas,
          );
        }
      }

      state = state.copyWith(isLoading: false, ventas: resultados);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> obtenerVentasPorRango(String empresaId, DateTime desde, DateTime hasta) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _obtenerPorRango(ObtenerVentasPorRangoParams(empresaId: empresaId, desde: desde, hasta: hasta));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (ventas) => state = state.copyWith(isLoading: false, ventas: ventas),
    );
  }

  Future<void> cambiarEstado(String ventaId, String nuevoEstado) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _cambiarEstado(CambiarEstadoParams(ventaId: ventaId, nuevoEstado: nuevoEstado));
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        // Actualizar la venta en la lista local
        final updatedVentas = state.ventas.map((v) {
          if (v.id == ventaId) {
            return v.copyWith(estado: nuevoEstado, updatedAt: DateTime.now());
          }
          return v;
        }).toList();
        state = state.copyWith(isLoading: false, ventas: updatedVentas);
      },
    );
  }

  Future<void> limpiarCacheLocal() async {
    await _pendingDao.deleteAllCacheVentas();
  }

  Venta _pendingToVenta(PendingVentaModel p) {
    return Venta(
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
      tipoTransferenciaId: p.tipoTransferenciaId,
      createdAt: DateTime.tryParse(p.createdAt) ?? DateTime.now(),
    );
  }

  void resetError() {
    state = state.copyWith(error: null);
  }
}
