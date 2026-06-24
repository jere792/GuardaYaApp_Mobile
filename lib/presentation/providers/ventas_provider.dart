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
import 'dart:convert';

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
  final int pendingCount;
  final Set<String> pendingSyncIds;

  const VentasState({
    this.ventas = const [],
    this.ventaSeleccionada,
    this.isLoading = false,
    this.error,
    this.showOfflineMessage = false,
    this.pendingCount = 0,
    this.pendingSyncIds = const {},
  });

  VentasState copyWith({
    List<Venta>? ventas,
    Venta? ventaSeleccionada,
    bool? isLoading,
    String? error,
    bool? showOfflineMessage,
    int? pendingCount,
    Set<String>? pendingSyncIds,
  }) {
    return VentasState(
      ventas: ventas ?? this.ventas,
      ventaSeleccionada: ventaSeleccionada ?? this.ventaSeleccionada,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      showOfflineMessage: showOfflineMessage ?? this.showOfflineMessage,
      pendingCount: pendingCount ?? this.pendingCount,
      pendingSyncIds: pendingSyncIds ?? this.pendingSyncIds,
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

    final allPending = await _pendingDao.getAllPendingVentas();
    final notSynced = allPending.where((p) => p.syncStatus != 'synced').toList();
    final pendingToShow = allPending.where((p) => p.syncStatus == 'pending' || p.syncStatus == 'error').toList();
    final pendingVentas = pendingToShow.map((p) => _pendingToVenta(p)).toList();
    final idsNotSynced = notSynced.map((p) => p.id).toSet();

    if (errorMsg != null) {
      final map = <String, Venta>{};
      for (final v in pendingVentas) {
        map[v.id] = v;
      }
      state = state.copyWith(
        isLoading: false,
        ventas: map.values.toList(),
        showOfflineMessage: true,
        pendingCount: notSynced.length,
        pendingSyncIds: idsNotSynced,
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
      state = state.copyWith(
        isLoading: false,
        ventas: map.values.toList(),
        pendingCount: notSynced.length,
        pendingSyncIds: idsNotSynced,
      );
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

      final all = await _pendingDao.getAllPendingVentas();
      final notSynced = all.where((p) => p.syncStatus != 'synced').toList();
      state = state.copyWith(
        isLoading: false,
        ventas: resultados,
        pendingCount: notSynced.length,
        pendingSyncIds: notSynced.map((p) => p.id).toSet(),
      );
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

  Future<void> loadPendingCount() async {
    final all = await _pendingDao.getAllPendingVentas();
    final notSynced = all.where((p) => p.syncStatus != 'synced').toList();
    state = state.copyWith(
      pendingCount: notSynced.length,
      pendingSyncIds: notSynced.map((p) => p.id).toSet(),
    );
  }

  Future<void> syncPendingVentas() async {
    if (state.pendingCount == 0) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final all = await _pendingDao.getAllPendingVentas();
      final toSync = all.where((p) => p.syncStatus != 'synced').toList();
      if (toSync.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final datasource = VentasDatasource();
      for (final p in toSync) {
        try {
          final ventaMap = p.toMap();
          ventaMap.remove('sync_status');
          ventaMap.remove('sync_error');
          ventaMap.remove('retry_count');
          ventaMap.remove('imagen_yape_local_path');
          ventaMap.remove('imagen_entrega_local_path');
          ventaMap.remove('productos');

          if (ventaMap['fecha_yape'] != null && ventaMap['fecha_yape'] is String) {
            ventaMap['fecha_yape'] = _parseFechaToIso(ventaMap['fecha_yape'] as String);
          }
          ventaMap['created_at'] = ventaMap['created_at'] ?? DateTime.now().toIso8601String();

          final created = await datasource.registrarVenta(ventaMap);

          if (p.productos != null && p.productos!.isNotEmpty) {
            try {
              final productosList = jsonDecode(p.productos!) as List<dynamic>;
              final payload = productosList.map((prod) => {
                'venta_id': created['id'],
                'empresa_id': p.empresaId,
                'nombre': prod['nombre'],
                'cantidad': prod['cantidad'],
                'precio_unitario': prod['precio'],
                'subtotal': prod['subtotal'],
              }).toList();
              await datasource.registrarVentaProductos(created['id'], p.empresaId, payload);
            } catch (_) {}
          }

          await _pendingDao.updateSyncStatus(p.id, 'synced');
        } catch (e) {
          await _pendingDao.updateSyncStatus(p.id, 'error',
            error: e.toString(),
            retryCount: p.retryCount + 1,
          );
        }
      }

      await loadPendingCount();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  String? _parseFechaToIso(String fecha) {
    try {
      final parts = fecha.split(RegExp(r'[/-]'));
      if (parts.length == 3 && parts[0].length <= 2) {
        final dia = parts[0].padLeft(2, '0');
        final mes = parts[1].padLeft(2, '0');
        final anio = parts[2].length == 2 ? '20${parts[2]}' : parts[2];
        return '$anio-$mes-${dia}T00:00:00.000Z';
      }
      const meses = {
        'ene': '01', 'feb': '02', 'mar': '03', 'abr': '04',
        'may': '05', 'jun': '06', 'jul': '07', 'ago': '08',
        'sep': '09', 'oct': '10', 'nov': '11', 'dic': '12',
      };
      final textMatch = RegExp(r'(\d{1,2})\s+([a-z]{3})[a-z]*\.?\s+(\d{4})', caseSensitive: false).firstMatch(fecha);
      if (textMatch != null) {
        final dia = textMatch.group(1)!.padLeft(2, '0');
        final mes = meses[textMatch.group(2)!.toLowerCase()] ?? '01';
        final anio = textMatch.group(3)!;
        return '$anio-$mes-${dia}T00:00:00.000Z';
      }
    } catch (_) {}
    return fecha;
  }

  void resetError() {
    state = state.copyWith(error: null);
  }
}
